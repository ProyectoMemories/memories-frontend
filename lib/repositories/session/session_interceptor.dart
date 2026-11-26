import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../api_error.dart';
import 'token_store.dart';

/// Pone el token de acceso en cada petición que lo pide, lo renueva cuando la
/// API responde `access_token_expired` y cierra la sesión cuando la API dice
/// que ya no vale (D56, CLAUDE.md §8, design.md §5).
///
/// Las renovaciones van de una en una porque [_refresh] pasa por el
/// `RefreshGate` compartido (lo arma `memoriesApiProvider`).
class SessionInterceptor extends Interceptor {
  SessionInterceptor({
    required this._dio,
    required this._tokenStore,
    required this._refresh,
    required this._onSessionExpired,
  });

  static const _retriedKey = 'memories.session_retried';

  final Dio _dio;
  final TokenStore _tokenStore;
  final Future<SessionTokens> Function() _refresh;
  final void Function() _onSessionExpired;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_needsAccessToken(options)) {
      final tokens = await _tokenStore.read();
      if (tokens != null) _setBearer(options, tokens.accessToken);
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final sentToken = _bearerOf(request);

    // Sesión revocada en otro dispositivo o cuenta desactivada: el token de
    // acceso todavía no vence, pero la API ya no lo acepta.
    if (_hasCode(err, ApiErrorCode.notAuthenticated) && sentToken != null) {
      await _endSession();
      return handler.next(err);
    }
    if (!_hasCode(err, ApiErrorCode.accessTokenExpired) ||
        request.extra[_retriedKey] == true) {
      return handler.next(err);
    }

    final SessionTokens tokens;
    try {
      tokens = await _renewedTokens(sentToken: sentToken);
    } on ApiError catch (failure) {
      if (failure.code == ApiErrorCode.invalidRefreshToken) await _endSession();
      // Sin conexión la sesión se mantiene; la petición falla con `network`.
      return handler.next(_renewalFailed(request, failure));
    } catch (error, stackTrace) {
      _report(error, stackTrace, 'al renovar el token de acceso');
      return handler.next(
        _renewalFailed(request, const ApiError(ApiErrorCode.unknown)),
      );
    }

    _setBearer(request, tokens.accessToken);
    request.extra[_retriedKey] = true;
    try {
      handler.resolve(await _dio.fetch<Object?>(request));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  /// Tokens con los que repetir la petición.
  Future<SessionTokens> _renewedTokens({required String? sentToken}) async {
    final current = await _tokenStore.read();
    if (current == null && sentToken != null) {
      // La sesión terminó mientras la petición iba en camino.
      throw const ApiError(ApiErrorCode.invalidRefreshToken);
    }
    // La petición salió antes de que otra renovara: basta con el token nuevo.
    if (current != null && current.accessToken != sentToken) return current;
    return _refresh();
  }

  /// Borra los tokens y avisa. Nunca lanza: el interceptor siempre tiene que
  /// responder la petición.
  Future<void> _endSession() async {
    try {
      await _tokenStore.clear();
    } catch (error, stackTrace) {
      _report(error, stackTrace, 'al borrar los tokens de la sesión');
    }
    try {
      _onSessionExpired();
    } catch (error, stackTrace) {
      _report(error, stackTrace, 'al avisar que la sesión terminó');
    }
  }

  /// La petición falla con el error de la renovación, para que el repositorio
  /// lo traduzca a `network` o `invalidRefreshToken` y no a "token vencido".
  static DioException _renewalFailed(RequestOptions request, ApiError cause) {
    return DioException(
      requestOptions: request,
      error: cause,
      message: 'No se pudo renovar la sesión (${cause.code.name}).',
    );
  }

  static void _report(Object error, StackTrace stackTrace, String context) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'memories',
        context: ErrorDescription(context),
      ),
    );
  }

  static bool _needsAccessToken(RequestOptions options) {
    final secure = options.extra['secure'];
    return secure is List && secure.isNotEmpty;
  }

  static bool _hasCode(DioException error, ApiErrorCode code) {
    final body = error.response?.data;
    return error.response?.statusCode == 401 &&
        body is Map &&
        body['code'] == code.wireName;
  }

  static void _setBearer(RequestOptions options, String accessToken) {
    options.headers['Authorization'] = 'Bearer $accessToken';
  }

  static String? _bearerOf(RequestOptions options) {
    final header = options.headers['Authorization'];
    return header is String && header.startsWith('Bearer ')
        ? header.substring('Bearer '.length)
        : null;
  }
}
