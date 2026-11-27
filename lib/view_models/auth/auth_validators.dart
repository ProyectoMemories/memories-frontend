/// Lo que la app revisa antes de enviar, igual que la API (RN-08, RN-10, D40,
/// D62-B), para marcar el campo sin esperar. La API lo vuelve a revisar.
/// Cada función devuelve el mensaje del campo, o null si está bien.
abstract final class AuthValidators {
  static const minimumAge = 14;

  static final _usernameChars = RegExp(r'^[A-Za-z0-9._]+$');

  // Suficiente para atrapar errores de tipeo; el formato exacto lo decide la
  // API.
  static final _emailShape = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? required(String value, String message) =>
      value.trim().isEmpty ? message : null;

  /// Nombres y apellidos: hasta 100 caracteres, como la API.
  static String? name(String value, {String? emptyMessage}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return emptyMessage;
    if (trimmed.runes.length > 100) return 'Usa hasta 100 caracteres.';
    return null;
  }

  /// RN-10 y D40, con los mismos mensajes de la API.
  static String? username(String value) {
    if (value.isEmpty) return 'Escribe un nombre de usuario.';
    if (value.length < 3 || value.length > 30) {
      return 'Debe tener entre 3 y 30 caracteres.';
    }
    if (!_usernameChars.hasMatch(value)) {
      return "Solo puede tener letras sin tilde, números, '.' y '_'.";
    }
    if (value.startsWith('.') || value.endsWith('.')) {
      return "No puede empezar ni terminar con '.'.";
    }
    if (value.contains('..')) return "No puede tener dos '.' seguidos.";
    return null;
  }

  static String? email(String value) {
    if (value.isEmpty) return 'Escribe tu correo.';
    if (value.length > 254 || !_emailShape.hasMatch(value)) {
      return 'Escribe un correo válido.';
    }
    return null;
  }

  /// D62-B: de 8 a 64 caracteres, contados como la API (no en UTF-16).
  static String? newPassword(String value) {
    if (value.isEmpty) return 'Escribe una contraseña.';
    final length = value.runes.length;
    if (length < 8 || length > 64) return 'Usa de 8 a 64 caracteres.';
    return null;
  }

  /// Edad cumplida en [today], como `age_on` de la API.
  static int ageOn(DateTime birthDate, DateTime today) {
    final hadBirthday =
        today.month > birthDate.month ||
        (today.month == birthDate.month && today.day >= birthDate.day);
    return today.year - birthDate.year - (hadBirthday ? 0 : 1);
  }
}
