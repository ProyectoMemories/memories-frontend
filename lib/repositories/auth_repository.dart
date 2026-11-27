import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memories_api/memories_api.dart';

import 'api_client.dart';
import 'api_error.dart';
import 'session/refresh_gate.dart';
import 'session/token_store.dart';

/// Único punto de la app que usa los endpoints de auth: registro,
/// verificación y sesión (D56).
///
/// En Android el token de renovación viaja en el cuerpo; en web, en la cookie
/// `HttpOnly`, así que esas peticiones van sin cuerpo.
class AuthRepository {
  AuthRepository({
    required this._api,
    required this._tokenStore,
    required this._platform,
    required this._refreshGate,
  });

  final AuthApi _api;
  final TokenStore _tokenStore;
  final ClientPlatform _platform;
  final RefreshGate _refreshGate;

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
    await _saveTokens(response.data);
  }

  /// Crea la cuenta sin verificar; la API manda el correo de verificación.
  Future<void> register(Registration registration) async {
    final request = RegisterRequest(
      (b) => b
        ..username = registration.username
        ..email = registration.email
        ..password = registration.password
        ..firstName = registration.firstName
        ..paternalSurname = registration.paternalSurname
        ..maternalSurname = registration.maternalSurname
        ..birthDate = Date(
          registration.birthDate.year,
          registration.birthDate.month,
          registration.birthDate.day,
        )
        ..acceptsPrivacyPolicy = registration.acceptsPrivacyPolicy,
    );
    await _call(
      () => _api.registerApiV1AuthRegisterPost(registerRequest: request),
    );
  }

  /// Activa la cuenta con el token del enlace del correo.
  Future<void> verifyEmail(String token) => _call(
    () => _api.verifyEmailApiV1AuthVerifyEmailPost(
      verifyEmailRequest: VerifyEmailRequest((b) => b..token = token),
    ),
  );

  /// Reenvía el enlace. La API responde igual exista o no la cuenta (D74).
  Future<void> resendVerification(String email) => _call(
    () => _api.resendVerificationApiV1AuthVerifyEmailResendPost(
      resendVerificationRequest: ResendVerificationRequest(
        (b) => b..email = email,
      ),
    ),
  );

  /// Pide un token de acceso nuevo; la API rota también el de renovación.
  /// Si ya hay una renovación en curso, espera esa en vez de pedir otra.
  Future<SessionTokens> refresh() => _refreshGate.run(_refreshNow);

  /// Revoca la sesión en la API y borra los tokens locales, aunque la API
  /// falle: quien cierra sesión no debe quedar dentro.
  Future<void> logout() async {
    try {
      // Con una renovación en curso, el token guardado está por rotar: se
      // espera para mandar el nuevo (el viejo se vería como reuso).
      await _refreshGate.idle();
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

  Future<SessionTokens> _refreshNow() async {
    final response = await _call(
      () async => _api.refreshApiV1AuthRefreshPost(
        refreshTokenRequest: await _refreshTokenRequest(),
      ),
    );
    return _saveTokens(response.data);
  }

  Future<SessionTokens> _saveTokens(TokenResponse? body) async {
    // Un 200 sin cuerpo no debería llegar; si llega, es un error de la API.
    if (body == null) throw const ApiError(ApiErrorCode.unknown);
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

/// Datos de los dos pasos del registro (HU-02), ya revisados por la app.
class Registration {
  const Registration({
    required this.username,
    required this.email,
    required this.password,
    required this.firstName,
    required this.paternalSurname,
    required this.maternalSurname,
    required this.birthDate,
    required this.acceptsPrivacyPolicy,
  });

  final String username;
  final String email;
  final String password;
  final String firstName;
  final String paternalSurname;
  final String? maternalSurname;

  /// Solo cuenta el día; la hora se ignora.
  final DateTime birthDate;
  final bool acceptsPrivacyPolicy;
}

/// Plataforma que la app declara al iniciar sesión, sin `dart:io`.
const currentClientPlatform = kIsWeb
    ? ClientPlatform.web
    : ClientPlatform.android;

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    api: ref.watch(memoriesApiProvider).getAuthApi(),
    tokenStore: ref.watch(tokenStoreProvider),
    platform: currentClientPlatform,
    refreshGate: ref.watch(refreshGateProvider),
  ),
);
