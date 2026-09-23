import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// Implementacion del contrato de autenticacion.
///
/// Es la unica pieza que sabe que existen tokens guardados: ni el controlador ni
/// las pantallas los tocan.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoto,
    required TokenStorage almacen,
  })  : _remoto = remoto,
        _almacen = almacen;

  final AuthRemoteDataSource _remoto;
  final TokenStorage _almacen;

  @override
  Future<AppUser> registrar({
    required String email,
    required String displayName,
    required String password,
  }) {
    return _remoto.registrar(
      email: email,
      displayName: displayName,
      password: password,
    );
  }

  @override
  Future<AuthSession> iniciarSesion({
    required String email,
    required String password,
  }) async {
    final AuthSession sesion = await _remoto.iniciarSesion(
      email: email,
      password: password,
    );
    await _almacen.save(
      accessToken: sesion.accessToken,
      refreshToken: sesion.refreshToken,
    );
    return sesion;
  }

  @override
  Future<void> cerrarSesion() async {
    final String? refreshToken = await _almacen.readRefreshToken();
    await _remoto.cerrarSesion(refreshToken);
    await _almacen.clear();
  }

  @override
  Future<AppUser?> usuarioActual() async {
    if (!await _almacen.hasSession) {
      return null;
    }
    try {
      return await _remoto.perfil();
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        // La sesion guardada ya no vale: se limpia y se empieza de cero.
        await _almacen.clear();
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<AppUser> actualizarNombre(String displayName) =>
      _remoto.actualizarNombre(displayName);
}
