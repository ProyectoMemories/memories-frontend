import 'package:dio/dio.dart';

/// Error de la API ya traducido a algo que la interfaz puede mostrar.
///
/// El backend responde siempre con la misma forma:
/// `{"error": {"code", "message", "details", "request_id"}}`,
/// asi que la traduccion ocurre en un unico sitio: aqui.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.code = 'unknown_error',
    this.statusCode,
    this.requestId,
  });

  final String message;
  final String code;
  final int? statusCode;
  final String? requestId;

  bool get isUnauthorized => statusCode == 401;

  bool get isNotFound => statusCode == 404;

  factory ApiException.fromDio(DioException error) {
    final Response<dynamic>? response = error.response;

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const ApiException(
        message: 'La conexion tardo demasiado. Intentalo de nuevo.',
        code: 'timeout',
      );
    }

    if (error.type == DioExceptionType.connectionError || response == null) {
      return const ApiException(
        message: 'No se pudo conectar con el servidor.',
        code: 'connection_error',
      );
    }

    final dynamic data = response.data;
    if (data is Map<String, dynamic> && data['error'] is Map<String, dynamic>) {
      final Map<String, dynamic> detail = data['error'] as Map<String, dynamic>;
      return ApiException(
        message: (detail['message'] as String?) ?? 'Ocurrio un error.',
        code: (detail['code'] as String?) ?? 'unknown_error',
        statusCode: response.statusCode,
        requestId: detail['request_id'] as String?,
      );
    }

    return ApiException(
      message: 'Ocurrio un error inesperado.',
      statusCode: response.statusCode,
    );
  }

  @override
  String toString() => 'ApiException($code): $message';
}
