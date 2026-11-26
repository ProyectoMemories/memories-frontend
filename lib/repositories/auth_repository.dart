import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memories_api/memories_api.dart';

import 'api_client.dart';
import 'api_error.dart';
import 'session/token_store.dart';

/// Único punto de la app que usa los endpoints de sesión (D56).
///
/// En Android el token de renovación viaja en el cuerpo; en web, en la cookie
/// `HttpOnly`, así que esas peticiones van sin cuerpo.
class AuthRepository {
  AuthRepository({
    required this._api,
    required this._tokenStore,
    required this._platform,
  });

  final AuthApi _api;
  final TokenStore _tokenStore;
  final ClientPlatform _platform;

  bool get _isWeb => _platform == ClientPlatform.web;

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    final request = LoginRequest(
      (b) => b
        ..identifier = identifier
        ..password = password
        ..platform = _platform,
    );
    final response = await _call(
      () => _api.loginApiV1AuthLoginPost(loginRequest: request),
    );
    await _saveTokens(response.data!);
  }

  /// Pide un token de acceso nuevo; la API rota también el de renovación.
  Future<SessionTokens> refresh() async {
    final response = await _call(
      () async => _api.refreshApiV1AuthRefreshPost(
        refreshTokenRequest: await _refreshTokenRequest(),
      ),
    );
    return _saveTokens(response.data!);
  }

  /// Revoca la sesión en la API y borra los tokens locales, aunque la API
  /// falle: quien cierra sesión no debe quedar dentro.
  Future<void> logout() async {
    try {
      final request = await _refreshTokenRequest(required: false);
      await _call(
        () => _api.logoutApiV1AuthLogoutPost(refreshTokenRequest: request),
      );
    } finally {
      await _tokenStore.clear();
    }
  }

  /// Cuerpo de `refresh` y `logout`: null en web (va la cookie).
  Future<RefreshTokenRequest?> _refreshTokenRequest({
    bool required = true,
  }) async {
    if (_isWeb) return null;
    final refreshToken = (await _tokenStore.read())?.refreshToken;
    if (refreshToken == null) {
      if (!required) return null;
      throw const ApiError(ApiErrorCode.invalidRefreshToken);
    }
    return RefreshTokenRequest((b) => b..refreshToken = refreshToken);
  }

  Future<SessionTokens> _saveTokens(TokenResponse body) async {
    final tokens = SessionTokens(
      accessToken: body.accessToken,
      refreshToken: body.refreshToken,
    );
    await _tokenStore.save(tokens);
    return tokens;
  }

  Future<T> _call<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw ApiError.fromDio(error);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    api: ref.watch(memoriesApiProvider).getAuthApi(),
    tokenStore: ref.watch(tokenStoreProvider),
    platform: kIsWeb ? ClientPlatform.web : ClientPlatform.android,
  ),
);
