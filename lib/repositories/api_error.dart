import 'package:dio/dio.dart';

/// Errores de la API que la app sabe manejar (design.md §6). Las vistas y los
/// ViewModels solo ven esto, nunca tipos de dio (CLAUDE.md §7).
enum ApiErrorCode {
  invalidCredentials('invalid_credentials'),
  emailNotVerified('email_not_verified'),
  accountSuspended('account_suspended'),
  tooManyRequests('too_many_requests'),
  usernameTaken('username_taken'),
  emailTaken('email_taken'),
  passwordLength('password_length'),
  passwordTooCommon('password_too_common'),
  underage('underage'),
  privacyPolicyNotAccepted('privacy_policy_not_accepted'),
  expiredToken('expired_token'),
  invalidToken('invalid_token'),
  currentPasswordIncorrect('current_password_incorrect'),
  invalidRefreshToken('invalid_refresh_token'),
  notAuthenticated('not_authenticated'),
  accessTokenExpired('access_token_expired'),
  originNotAllowed('origin_not_allowed'),

  /// Sin conexión, tiempo agotado o error 5xx: el mismo mensaje para todos.
  network(null),

  /// Un `code` que esta versión de la app todavía no conoce.
  unknown(null);

  const ApiErrorCode(this.wireName);

  /// Valor de `code` en la respuesta de la API.
  final String? wireName;

  static ApiErrorCode fromWire(Object? code) => values.firstWhere(
    (value) => value.wireName != null && value.wireName == code,
    orElse: () => unknown,
  );
}

class ApiError implements Exception {
  const ApiError(this.code, {this.retryAfter});

  /// Traduce el error de dio al de la app.
  factory ApiError.fromDio(DioException error) {
    final response = error.response;
    if (response == null || response.statusCode! >= 500) {
      return const ApiError(ApiErrorCode.network);
    }
    final body = response.data;
    final code = body is Map ? body['code'] : null;
    return ApiError(
      ApiErrorCode.fromWire(code),
      retryAfter: _parseRetryAfter(response.headers.value('retry-after')),
    );
  }

  final ApiErrorCode code;

  /// Cuánto esperar antes de reintentar (`Retry-After`, D70, D77).
  final Duration? retryAfter;

  static Duration? _parseRetryAfter(String? header) {
    final seconds = header == null ? null : int.tryParse(header);
    return seconds == null ? null : Duration(seconds: seconds);
  }

  @override
  String toString() => 'ApiError(${code.name})';
}
