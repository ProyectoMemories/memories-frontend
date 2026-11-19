/// URL de la API, recibida al compilar con `--dart-define=API_BASE_URL=...`.
///
/// Entra por variable de compilación para no escribir entornos en el código.
const String apiBaseUrlFromEnvironment = String.fromEnvironment('API_BASE_URL');

/// Comprueba la URL de la API al arrancar, para que un error de configuración
/// se vea en ese momento y no en la primera petición.
String validateApiBaseUrl(String value) {
  final uri = Uri.tryParse(value);
  final isHttp = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  if (!isHttp || uri.host.isEmpty) {
    throw StateError(
      'API_BASE_URL no es válida: "$value". '
      'Usa --dart-define=API_BASE_URL=http://localhost:8001',
    );
  }
  return value;
}
