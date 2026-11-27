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

  /// 422 de formato: la API dice qué campos estaban mal en [ApiError.fields].
  validationError('validation_error'),

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
  const ApiError(this.code, {this.retryAfter, this.fields = const {}});

  /// Traduce el error de dio al de la app.
  factory ApiError.fromDio(DioException error) {
    // El interceptor deja así el error de una renovación que falló.
    final cause = error.error;
    if (cause is ApiError) return cause;
    final response = error.response;
    final status = response?.statusCode;
    if (response == null || status == null || status >= 500) {
      return const ApiError(ApiErrorCode.network);
    }
    final body = response.data;
    final code = body is Map ? body['code'] : null;
    return ApiError(
      ApiErrorCode.fromWire(code),
      retryAfter: _parseRetryAfter(response.headers.value('retry-after')),
      fields: _parseFields(body),
    );
  }

  final ApiErrorCode code;

  /// Cuánto esperar antes de reintentar (`Retry-After`, D70, D77).
  final Duration? retryAfter;

  /// Campos que la API rechazó por formato (`validation_error`), con el
  /// nombre del JSON (`email`, `username`…). El mensaje lo pone la app.
  final Set<String> fields;

  static Set<String> _parseFields(Object? body) {
    final errors = body is Map ? body['errors'] : null;
    if (errors is! List) return const {};
    return {
      for (final error in errors)
        if (error is Map && error['field'] is String) error['field'] as String,
    };
  }

  static Duration? _parseRetryAfter(String? header) {
    final seconds = header == null ? null : int.tryParse(header);
    return seconds == null ? null : Duration(seconds: seconds);
  }

  @override
  String toString() => 'ApiError(${code.name})';
}
