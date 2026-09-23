/// Todas las rutas de la API, en un unico sitio.
///
/// Regla del proyecto: **ninguna URL escrita dentro de un servicio o de una
/// pantalla**. Si un endpoint cambia, se cambia aqui y en ningun otro lugar.
class ApiEndpoints {
  const ApiEndpoints._();

  // ─── Autenticacion ────────────────────────────────────────────────
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';

  // ─── Usuarios ─────────────────────────────────────────────────────
  static const String me = '/users/me';

  // ─── Fotografias ──────────────────────────────────────────────────
  static const String photos = '/photos';

  static String photoRaw(String photoId) => '/photos/$photoId/raw';

  static String photo(String photoId) => '/photos/$photoId';

  // ─── Recuerdos ────────────────────────────────────────────────────
  static const String memories = '/memories';
  static const String calendar = '/memories/calendar';
  static const String revive = '/memories/revive';

  static String memory(String memoryId) => '/memories/$memoryId';

  static String memoryPhotos(String memoryId) => '/memories/$memoryId/photos';

  static String memoryPhoto(String memoryId, String photoId) =>
      '/memories/$memoryId/photos/$photoId';
}
