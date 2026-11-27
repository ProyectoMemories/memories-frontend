import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/repositories/api_error.dart';
import 'package:memories/repositories/auth_repository.dart';
import 'package:memories/repositories/session/token_store.dart';
import 'package:memories/view_models/auth/login_view_model.dart';
import 'package:memories/view_models/auth/session_notifier.dart';

import '../../repositories/fake_http_adapter.dart';
import 'session_notifier_test.dart' show FakeAuthRepository;

void main() {
  late FakeAuthRepository repository;
  late ProviderContainer container;
  late List<({String identifier, String password})> logins;

  setUp(() async {
    repository = FakeAuthRepository();
    logins = [];
    repository.onLogin = () async {};
    container = ProviderContainer.test(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          _RecordingRepository(repository, logins),
        ),
        tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
      ],
    );
    // La sesión empieza "sin sesión", como en la pantalla de login.
    container.listen(sessionProvider, (_, _) {});
    // autoDispose: sin alguien que escuche, el estado se descartaría.
    container.listen(loginViewModelProvider, (_, _) {});
    await pumpEventQueue();
  });

  LoginViewModel viewModel() => container.read(loginViewModelProvider.notifier);
  LoginState state() => container.read(loginViewModelProvider);

  Future<String?> errorFor(ApiError error) async {
    repository.onLogin = () async => throw error;
    await viewModel().submit(identifier: 'ana', password: 'clave-segura');
    return state().errorMessage;
  }

  test(
    'datos correctos: la sesión pasa a "con sesión" y no hay error',
    () async {
      await viewModel().submit(identifier: 'ana', password: 'clave-segura');

      expect(container.read(sessionProvider), SessionStatus.signedIn);
      expect(state().errorMessage, isNull);
      expect(state().isSubmitting, isFalse);
    },
  );

  test('quita los espacios del usuario, no de la contraseña', () async {
    await viewModel().submit(
      identifier: '  ana@ejemplo.pe ',
      password: ' clave con espacios ',
    );

    expect(logins.single.identifier, 'ana@ejemplo.pe');
    expect(logins.single.password, ' clave con espacios ');
  });

  test('mientras espera, está enviando y no acepta otro envío', () async {
    final answer = Completer<void>();
    repository.onLogin = () => answer.future;

    final first = viewModel().submit(identifier: 'ana', password: 'clave');
    expect(state().isSubmitting, isTrue);
    await viewModel().submit(identifier: 'ana', password: 'clave');
    answer.complete();
    await first;

    expect(logins, hasLength(1));
    expect(state().isSubmitting, isFalse);
  });

  test('datos incorrectos: error genérico (D62-E)', () async {
    expect(
      await errorFor(const ApiError(ApiErrorCode.invalidCredentials)),
      'El usuario o la contraseña no son correctos.',
    );
    expect(container.read(sessionProvider), SessionStatus.signedOut);
  });

  test('cuenta sin verificar: avisa que revise su correo', () async {
    expect(
      await errorFor(const ApiError(ApiErrorCode.emailNotVerified)),
      'Tu cuenta todavía no está verificada. Revisa tu correo para '
      'activarla.',
    );
  });

  test('cuenta suspendida: lo dice sin más detalle', () async {
    expect(
      await errorFor(const ApiError(ApiErrorCode.accountSuspended)),
      'Esta cuenta está suspendida.',
    );
  });

  test('demasiados intentos: cuántos segundos esperar (D70, D77)', () async {
    expect(
      await errorFor(
        const ApiError(
          ApiErrorCode.tooManyRequests,
          retryAfter: Duration(seconds: 42),
        ),
      ),
      'Demasiados intentos. Prueba en 42 segundos.',
    );
  });

  test('demasiados intentos con 1 segundo: en singular', () async {
    expect(
      await errorFor(
        const ApiError(
          ApiErrorCode.tooManyRequests,
          retryAfter: Duration(seconds: 1),
        ),
      ),
      'Demasiados intentos. Prueba en 1 segundo.',
    );
  });

  test('demasiados intentos sin Retry-After: sin número', () async {
    expect(
      await errorFor(const ApiError(ApiErrorCode.tooManyRequests)),
      'Demasiados intentos. Prueba en un momento.',
    );
  });

  test('sin conexión: mensaje de conexión', () async {
    expect(
      await errorFor(const ApiError(ApiErrorCode.network)),
      'No pudimos conectar. Revisa tu conexión e inténtalo de nuevo.',
    );
  });

  test('un error no previsto: mensaje general', () async {
    expect(
      await errorFor(const ApiError(ApiErrorCode.unknown)),
      'Algo salió mal. Inténtalo de nuevo.',
    );
  });

  test('sin contraseña: marca el campo y no llama a la API', () async {
    await viewModel().submit(identifier: 'ana', password: '');

    expect(state().passwordError, 'Escribe tu contraseña.');
    expect(state().identifierError, isNull);
    expect(logins, isEmpty);
  });

  test(
    'sin usuario (o solo espacios): marca el campo y no llama a la API',
    () async {
      await viewModel().submit(identifier: '   ', password: 'clave-segura');

      expect(state().identifierError, 'Escribe tu correo o nombre de usuario.');
      expect(state().passwordError, isNull);
      expect(logins, isEmpty);
    },
  );

  test('con los dos vacíos marca los dos', () async {
    await viewModel().submit(identifier: '', password: '');

    expect(state().identifierError, isNotNull);
    expect(state().passwordError, isNotNull);
  });

  test('al completar los campos, se borran sus errores', () async {
    await viewModel().submit(identifier: '', password: '');

    await viewModel().submit(identifier: 'ana', password: 'clave-segura');

    expect(state().identifierError, isNull);
    expect(state().passwordError, isNull);
    expect(logins, hasLength(1));
  });

  test('un fallo inesperado (Keystore) no deja el botón cargando', () async {
    final reported = <FlutterErrorDetails>[];
    final previousOnError = FlutterError.onError;
    FlutterError.onError = reported.add;
    addTearDown(() => FlutterError.onError = previousOnError);
    repository.onLogin = () async => throw StateError('Keystore dañado');

    await viewModel().submit(identifier: 'ana', password: 'clave-segura');

    expect(state().isSubmitting, isFalse);
    expect(state().errorMessage, 'Algo salió mal. Inténtalo de nuevo.');
    expect(reported.single.exception, isA<StateError>());
  });

  test('al volver a intentar, el error anterior se borra', () async {
    await errorFor(const ApiError(ApiErrorCode.invalidCredentials));
    repository.onLogin = () async {};

    await viewModel().submit(identifier: 'ana', password: 'clave-segura');

    expect(state().errorMessage, isNull);
  });
}

/// Repositorio que anota cada login y delega en el doble.
class _RecordingRepository extends FakeAuthRepository {
  _RecordingRepository(this._inner, this._logins);

  final FakeAuthRepository _inner;
  final List<({String identifier, String password})> _logins;

  @override
  Future<void> login({required String identifier, required String password}) {
    _logins.add((identifier: identifier, password: password));
    return _inner.onLogin();
  }

  @override
  Future<SessionTokens> refresh() => _inner.refresh();
}
