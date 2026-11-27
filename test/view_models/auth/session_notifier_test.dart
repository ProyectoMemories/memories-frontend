import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/repositories/api_error.dart';
import 'package:memories/repositories/auth_repository.dart';
import 'package:memories/repositories/session/token_store.dart';
import 'package:memories/view_models/auth/session_notifier.dart';

import '../../repositories/fake_http_adapter.dart';

/// Doble del repositorio: cada método hace lo que el test le indique.
class FakeAuthRepository implements AuthRepository {
  Future<void> Function() onLogin = () async {};
  Future<SessionTokens> Function() onRefresh = () async =>
      throw const ApiError(ApiErrorCode.invalidRefreshToken);
  Future<void> Function() onLogout = () async {};
  Future<void> Function(Registration) onRegister = (_) async {};
  Future<void> Function(String) onVerifyEmail = (_) async {};
  Future<void> Function(String) onResendVerification = (_) async {};
  int refreshCalls = 0;

  @override
  Future<void> login({required String identifier, required String password}) =>
      onLogin();

  @override
  Future<SessionTokens> refresh() {
    refreshCalls++;
    return onRefresh();
  }

  @override
  Future<void> logout() => onLogout();

  @override
  Future<void> register(Registration registration) => onRegister(registration);

  @override
  Future<void> verifyEmail(String token) => onVerifyEmail(token);

  @override
  Future<void> resendVerification(String email) => onResendVerification(email);
}

/// TokenStore cuyo `read` falla, como un Keystore dañado.
class _BrokenReadTokenStore extends InMemoryTokenStore {
  @override
  Future<SessionTokens?> read() async => throw StateError('Keystore dañado');
}

void main() {
  late FakeAuthRepository repository;
  late InMemoryTokenStore store;

  ProviderContainer buildContainer() => ProviderContainer.test(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      tokenStoreProvider.overrideWithValue(store),
    ],
  );

  /// Lee el provider y espera a que termine de comprobar la sesión.
  Future<SessionStatus> restoredStatus(ProviderContainer container) async {
    expect(container.read(sessionProvider), SessionStatus.checking);
    await pumpEventQueue();
    return container.read(sessionProvider);
  }

  setUp(() {
    repository = FakeAuthRepository();
    store = InMemoryTokenStore();
  });

  group('al abrir la app', () {
    test('con tokens guardados (Android) sigue dentro sin renovar', () async {
      store.tokens = const SessionTokens(
        accessToken: 'acceso',
        refreshToken: 'sesion.secreto',
      );

      expect(await restoredStatus(buildContainer()), SessionStatus.signedIn);
      expect(repository.refreshCalls, 0);
    });

    test(
      'sin token en memoria (web) recupera la sesión con la cookie',
      () async {
        repository.onRefresh = () async =>
            const SessionTokens(accessToken: 'acceso-nuevo');

        expect(await restoredStatus(buildContainer()), SessionStatus.signedIn);
        expect(repository.refreshCalls, 1);
      },
    );

    test('sin sesión que recuperar, queda sin sesión', () async {
      expect(await restoredStatus(buildContainer()), SessionStatus.signedOut);
    });

    test('si leer los tokens falla (Keystore dañado), no se queda en '
        'comprobando', () async {
      final reported = <FlutterErrorDetails>[];
      final previousOnError = FlutterError.onError;
      FlutterError.onError = reported.add;
      addTearDown(() => FlutterError.onError = previousOnError);
      store = _BrokenReadTokenStore();

      expect(await restoredStatus(buildContainer()), SessionStatus.signedOut);
      expect(reported.single.exception, isA<StateError>());
    });

    test('sin conexión al recuperar, queda sin sesión', () async {
      repository.onRefresh = () async =>
          throw const ApiError(ApiErrorCode.network);

      expect(await restoredStatus(buildContainer()), SessionStatus.signedOut);
    });
  });

  test('logIn correcto pasa a con sesión', () async {
    final container = buildContainer();
    await restoredStatus(container);

    await container
        .read(sessionProvider.notifier)
        .logIn(identifier: 'ana', password: 'clave-segura');

    expect(container.read(sessionProvider), SessionStatus.signedIn);
  });

  test('logIn con error sigue sin sesión y deja ver el error', () async {
    repository.onLogin = () async =>
        throw const ApiError(ApiErrorCode.invalidCredentials);
    final container = buildContainer();
    await restoredStatus(container);

    await expectLater(
      container
          .read(sessionProvider.notifier)
          .logIn(identifier: 'ana', password: 'otra-clave'),
      throwsA(isA<ApiError>()),
    );
    expect(container.read(sessionProvider), SessionStatus.signedOut);
  });

  test('logOut deja sin sesión aunque la API falle', () async {
    store.tokens = const SessionTokens(accessToken: 'acceso');
    repository.onLogout = () async =>
        throw const ApiError(ApiErrorCode.network);
    final container = buildContainer();
    await restoredStatus(container);

    await expectLater(
      container.read(sessionProvider.notifier).logOut(),
      throwsA(isA<ApiError>()),
    );
    expect(container.read(sessionProvider), SessionStatus.signedOut);
  });

  test('sessionExpired (la renovación falló) vuelve a sin sesión', () async {
    store.tokens = const SessionTokens(accessToken: 'acceso');
    final container = buildContainer();
    await restoredStatus(container);

    container.read(sessionProvider.notifier).sessionExpired();

    expect(container.read(sessionProvider), SessionStatus.signedOut);
  });
}
