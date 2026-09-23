/// Validaciones de formulario.
///
/// Son una ayuda para escribir sin errores, no la regla de verdad: quien manda
/// es la API. Por eso repiten los limites del backend y nada mas.
class Validaciones {
  const Validaciones._();

  static final RegExp _correo = RegExp(r'^[^@\s]+@[^@\s]+\.[a-zA-Z]{2,}$');

  static const int minimoContrasena = 8;
  static const int maximoTitulo = 120;
  static const int maximoDescripcion = 2000;

  static String? correo(String? valor) {
    final String texto = (valor ?? '').trim();
    if (texto.isEmpty) {
      return 'Escribe tu correo.';
    }
    if (!_correo.hasMatch(texto)) {
      return 'Ese correo no parece valido.';
    }
    return null;
  }

  static String? contrasena(String? valor) {
    final String texto = valor ?? '';
    if (texto.isEmpty) {
      return 'Escribe tu contrasena.';
    }
    if (texto.length < minimoContrasena) {
      return 'Al menos $minimoContrasena caracteres.';
    }
    return null;
  }

  static String? obligatorio(String? valor, {String campo = 'Este campo'}) {
    if ((valor ?? '').trim().isEmpty) {
      return '$campo es obligatorio.';
    }
    return null;
  }

  static String? titulo(String? valor) {
    final String? vacio = obligatorio(valor, campo: 'El titulo');
    if (vacio != null) {
      return vacio;
    }
    if (valor!.trim().length > maximoTitulo) {
      return 'Maximo $maximoTitulo caracteres.';
    }
    return null;
  }

  static String? descripcion(String? valor) {
    if ((valor ?? '').length > maximoDescripcion) {
      return 'Maximo $maximoDescripcion caracteres.';
    }
    return null;
  }
}
