/// Configuracion del entorno.
///
/// Los valores llegan en tiempo de compilacion:
///   flutter run --dart-define-from-file=env/dev.json
///
/// Un solo codigo para movil y web: lo que cambia entre entornos es este
/// archivo JSON, nunca el codigo.
class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8001/api/v1',
  );

  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static bool get isDevelopment => appEnv == 'development';

  /// Tiempo maximo de espera de una peticion.
  static const Duration requestTimeout = Duration(seconds: 30);

  /// Subir fotos tarda mas que cualquier otra cosa.
  static const Duration uploadTimeout = Duration(seconds: 120);
}
