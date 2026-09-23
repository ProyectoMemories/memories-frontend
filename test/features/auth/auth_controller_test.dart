import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memories_app/features/auth/domain/entities/app_user.dart';
import 'package:memories_app/features/auth/domain/entities/auth_session.dart';
import 'package:memories_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:memories_app/features/auth/presentation/providers/auth_providers.dart';

const AppUser _victor = AppUser(
  id: '1',
  email: 'victor@memories.app',
  displayName: 'Victor',
  role: 'user',
  isActive: true,
);

/// Doble del repositorio: el controlador depende del contrato, no de la red,
/// asi que estos tests no necesitan servidor.
class _RepositorioFalso implements AuthRepository {
  _RepositorioFalso({this.usuarioGuardado, this.fallaElLogin = false});

  AppUser? usuarioGuardado;
  bool fallaElLogin;
  bool cerroSesion = false;

  @override
  Future<AuthSession> iniciarSesion({
    required String email,
    required String password,
  }) async {
    if (fallaElLogin) {
      throw Exception('Correo o contrasena incorrectos.');
    }
    usuarioGuardado = _victor;
    return const AuthSession(
      user: _victor,
      accessToken: 'acceso',
      refreshToken: 'refresco',
    );
  }

  @override
  Future<AppUser> registrar({
    required String email,
    required String displayName,
    required String password,
  }) async =>
      _victor;

  @override
  Future<void> cerrarSesion() async {
    cerroSesion = true;
    usuarioGuardado = null;
  }

  @override
  Future<AppUser?> usuarioActual() async => usuarioGuardado;

  @override
  Future<AppUser> actualizarNombre(String displayName) async => _victor;
}

ProviderContainer _contenedor(AuthRepository repositorio) {
  final ProviderContainer contenedor = ProviderContainer(
    overrides: <Override>[
      authRepositoryProvider.overrideWithValue(repositorio),
    ],
  );
  addTearDown(contenedor.dispose);
  return contenedor;
}

void main() {
  test('sin sesion guardada, nadie esta dentro', () async {
    final ProviderContainer contenedor = _contenedor(_RepositorioFalso());

    final AppUser? usuario = await contenedor.read(authControllerProvider.future);

    expect(usuario, isNull);
  });

  test('con sesion guardada, se recupera al arrancar', () async {
    final ProviderContainer contenedor =
        _contenedor(_RepositorioFalso(usuarioGuardado: _victor));

    final AppUser? usuario = await contenedor.read(authControllerProvider.future);

    expect(usuario?.email, 'victor@memories.app');
  });

  test('iniciar sesion deja al usuario en el estado', () async {
    final ProviderContainer contenedor = _contenedor(_RepositorioFalso());
    await contenedor.read(authControllerProvider.future);

    final bool correcto = await contenedor
        .read(authControllerProvider.notifier)
        .iniciarSesion(email: 'victor@memories.app', password: 'unaClaveSegura1');

    expect(correcto, isTrue);
    expect(contenedor.read(authControllerProvider).valueOrNull?.email,
        'victor@memories.app');
  });

  test('un login fallido deja el error en el estado y a nadie dentro', () async {
    final ProviderContainer contenedor =
        _contenedor(_RepositorioFalso(fallaElLogin: true));
    await contenedor.read(authControllerProvider.future);

    final bool correcto = await contenedor
        .read(authControllerProvider.notifier)
        .iniciarSesion(email: 'victor@memories.app', password: 'mal');

    expect(correcto, isFalse);
    expect(contenedor.read(authControllerProvider).hasError, isTrue);
  });

  test('cerrar sesion vacia el estado', () async {
    final _RepositorioFalso repositorio = _RepositorioFalso(usuarioGuardado: _victor);
    final ProviderContainer contenedor = _contenedor(repositorio);
    await contenedor.read(authControllerProvider.future);

    await contenedor.read(authControllerProvider.notifier).cerrarSesion();

    expect(repositorio.cerroSesion, isTrue);
    expect(contenedor.read(authControllerProvider).valueOrNull, isNull);
  });
}
