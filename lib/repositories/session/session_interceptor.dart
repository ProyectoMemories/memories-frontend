import 'dart:async';

import 'package:dio/dio.dart';

import '../api_error.dart';
import 'token_store.dart';

/// Pone el token de acceso en cada petición que lo pide y lo renueva solo
/// cuando la API responde `access_token_expired` (D56, CLAUDE.md §8).
///
/// Las renovaciones van de una en una: si dos peticiones fallan a la vez, la
/// primera renueva y las demás esperan su resultado. Dos renovaciones con el
/// mismo token se ven como reuso y la API revoca la sesión.
class SessionInterceptor extends Interceptor {
  SessionInterceptor({
    required this._dio,
    required this._tokenStore,
    required this._refresh,
    required this._onSessionExpired,
  });

  static const _retriedKey = 'memories.session_retried';

  /// Códigos con los que la sesión ya no vale y hay que volver al login.
  static const _sessionGoneCodes = {
    ApiErrorCode.invalidRefreshToken,
    ApiErrorCode.notAuthenticated,
  };

  final Dio _dio;
  final TokenStore _tokenStore;
  final Future<SessionTokens> Function() _refresh;
  final void Function() _onSessionExpired;

  Completer<SessionTokens?>? _refreshing;

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
    if (!_isAccessTokenExpired(err) || request.extra[_retriedKey] == true) {
      return handler.next(err);
    }

    final tokens = await _renewedTokens(sentToken: _bearerOf(request));
    if (tokens == null) return handler.next(err);

    _setBearer(request, tokens.accessToken);
    request.extra[_retriedKey] = true;
    try {
      handler.resolve(await _dio.fetch<Object?>(request));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  /// Tokens con los que repetir la petición, o null si no se pudo renovar.
  Future<SessionTokens?> _renewedTokens({required String? sentToken}) async {
    final inFlight = _refreshing;
    if (inFlight != null) return inFlight.future;

    // La petición salió antes de que otra renovara: basta con el token nuevo.
    final current = await _tokenStore.read();
    if (current != null && current.accessToken != sentToken) return current;

    // Otra petición pudo empezar a renovar mientras se leía el token.
    final completer = _refreshing;
    if (completer != null) return completer.future;
    return _startRefresh();
  }

  Future<SessionTokens?> _startRefresh() async {
    final completer = _refreshing = Completer<SessionTokens?>();
    try {
      final tokens = await _refresh();
      completer.complete(tokens);
    } on ApiError catch (error) {
      if (_sessionGoneCodes.contains(error.code)) {
        await _tokenStore.clear();
        _onSessionExpired();
      }
      // Sin conexión no se cierra la sesión: la petición falla y ya.
      completer.complete(null);
    } finally {
      _refreshing = null;
    }
    return completer.future;
  }

  static bool _needsAccessToken(RequestOptions options) {
    final secure = options.extra['secure'];
    return secure is List && secure.isNotEmpty;
  }

  static bool _isAccessTokenExpired(DioException error) {
    final body = error.response?.data;
    return error.response?.statusCode == 401 &&
        body is Map &&
        body['code'] == ApiErrorCode.accessTokenExpired.wireName;
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
