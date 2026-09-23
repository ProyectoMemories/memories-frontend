import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../providers/auth_providers.dart';

/// Estado de la sesion.
///
/// En MVVM este es el ViewModel de la autenticacion: las pantallas leen su
/// estado y llaman a sus metodos, sin saber que hay detras.
class AuthController extends AsyncNotifier<AppUser?> {
  AuthRepository get _repositorio => ref.read(authRepositoryProvider);

  @override
  Future<AppUser?> build() async {
    // Al arrancar se intenta recuperar la sesion guardada en el dispositivo.
    return _repositorio.usuarioActual();
  }

  Future<bool> iniciarSesion({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue<AppUser?>.loading();
    final AsyncValue<AppUser?> resultado = await AsyncValue.guard<AppUser?>(() async {
      final AuthSession sesion = await _repositorio.iniciarSesion(
        email: email,
        password: password,
      );
      return sesion.user;
    });
    state = resultado;
    return !resultado.hasError;
  }

  Future<bool> registrar({
    required String email,
    required String displayName,
    required String password,
  }) async {
    state = const AsyncValue<AppUser?>.loading();
    final AsyncValue<AppUser?> resultado = await AsyncValue.guard<AppUser?>(() async {
      await _repositorio.registrar(
        email: email,
        displayName: displayName,
        password: password,
      );
      // Registrarse deja la sesion abierta: nadie quiere escribir dos veces lo
      // mismo seguido.
      final AuthSession sesion = await _repositorio.iniciarSesion(
        email: email,
        password: password,
      );
      return sesion.user;
    });
    state = resultado;
    return !resultado.hasError;
  }

  Future<void> cerrarSesion() async {
    await _repositorio.cerrarSesion();
    state = const AsyncValue<AppUser?>.data(null);
  }

  Future<void> actualizarNombre(String displayName) async {
    state = await AsyncValue.guard<AppUser?>(
      () => _repositorio.actualizarNombre(displayName),
    );
  }

  /// La llama el cliente HTTP cuando la renovacion de la sesion falla.
  void sesionExpirada() {
    state = const AsyncValue<AppUser?>.data(null);
  }
}
