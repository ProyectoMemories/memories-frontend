/// La persona que usa la aplicacion.
///
/// Entidad de dominio: sin `fromJson` ni nada que sepa de la API. La traduccion
/// vive en `data/models/user_dto.dart`.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.isActive,
  });

  final String id;
  final String email;
  final String displayName;
  final String role;
  final bool isActive;

  bool get esSuperusuario => role == 'superuser';

  /// Iniciales para el avatar, sin depender de una foto de perfil.
  String get iniciales {
    final List<String> partes =
        displayName.trim().split(RegExp(r'\s+')).where((String p) => p.isNotEmpty).toList();
    if (partes.isEmpty) {
      return '?';
    }
    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }
    return (partes.first.substring(0, 1) + partes[1].substring(0, 1)).toUpperCase();
  }
}
