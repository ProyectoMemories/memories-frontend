import '../entities/app_user.dart';
import '../entities/auth_session.dart';

/// Contrato de la capa de datos para la autenticacion.
///
/// La presentacion depende de esta interfaz, no de Dio: por eso los tests de los
/// controladores no necesitan servidor.
abstract class AuthRepository {
  Future<AppUser> registrar({
    required String email,
    required String displayName,
    required String password,
  });

  Future<AuthSession> iniciarSesion({
    required String email,
    required String password,
  });

  Future<void> cerrarSesion();

  /// Devuelve la persona de la sesion guardada, o null si no hay ninguna valida.
  Future<AppUser?> usuarioActual();

  Future<AppUser> actualizarNombre(String displayName);
}
