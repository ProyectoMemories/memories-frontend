import '../../repositories/api_error.dart';

/// Mensajes de design.md §6 que comparten varias pantallas de auth.
abstract final class AuthMessages {
  static const unexpected = 'Algo salió mal. Inténtalo de nuevo.';
  static const network =
      'No pudimos conectar. Revisa tu conexión e inténtalo de nuevo.';
  static const linkInvalid = 'El enlace venció o ya se usó. Pide uno nuevo.';

  static String tooManyRequests(Duration? retryAfter) {
    final seconds = retryAfter?.inSeconds;
    if (seconds == null || seconds <= 0) {
      return 'Demasiados intentos. Prueba en un momento.';
    }
    final unit = seconds == 1 ? 'segundo' : 'segundos';
    return 'Demasiados intentos. Prueba en $seconds $unit.';
  }

  /// Lo que se dice cuando el error no tiene un lugar propio en la pantalla.
  static String general(ApiError error) => switch (error.code) {
    ApiErrorCode.tooManyRequests => tooManyRequests(error.retryAfter),
    ApiErrorCode.network => network,
    _ => unexpected,
  };
}
