import '../../domain/entities/app_user.dart';

/// Traduccion entre el JSON de la API y la entidad de dominio.
class UserDto {
  const UserDto._();

  static AppUser desdeJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String,
      role: json['role'] as String,
      isActive: (json['is_active'] as bool?) ?? true,
    );
  }
}
