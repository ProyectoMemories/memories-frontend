import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/repositories/api_error.dart';
import 'package:memories/repositories/auth_repository.dart';
import 'package:memories/repositories/session/token_store.dart';
import 'package:memories/view_models/auth/profile_view_model.dart';
import 'package:memories/view_models/auth/session_notifier.dart';

import '../../repositories/fake_http_adapter.dart';
import 'session_notifier_test.dart' show FakeAuthRepository;

void main() {
  late FakeAuthRepository repository;
  late ProviderContainer container;
  late int logouts;

  setUp(() async {
    logouts = 0;
    repository = FakeAuthRepository();
    repository.onLogout = () async => logouts++;
    container = ProviderContainer.test(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        // Con tokens guardados la sesión empieza "con sesión".
        tokenStoreProvider.overrideWithValue(
          InMemoryTokenStore(const SessionTokens(accessToken: 'acceso')),
        ),
      ],
    );
    container.listen(sessionProvider, (_, _) {});
    container.listen(profileViewModelProvider, (_, _) {});
    await pumpEventQueue();
  });

  ProfileViewModel viewModel() =>
      container.read(profileViewModelProvider.notifier);

  test('cerrar sesión revoca en la API y deja la app sin sesión', () async {
    await viewModel().logOut();

    expect(logouts, 1);
    expect(container.read(sessionProvider), SessionStatus.signedOut);
  });

  test('mientras cierra, lo indica y no acepta otro toque', () async {
    final answer = Completer<void>();
    repository.onLogout = () {
      logouts++;
      return answer.future;
    };

    final first = viewModel().logOut();
    expect(container.read(profileViewModelProvider).isLoggingOut, isTrue);
    await viewModel().logOut();
    answer.complete();
    await first;

    expect(logouts, 1);
  });

  test(
    'sin conexión igual sale: la sesión del dispositivo se cierra',
    () async {
      repository.onLogout = () async =>
          throw const ApiError(ApiErrorCode.network);

      await viewModel().logOut();

      expect(container.read(sessionProvider), SessionStatus.signedOut);
    },
  );
}
