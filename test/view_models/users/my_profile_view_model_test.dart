import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/repositories/api_error.dart';
import 'package:memories/repositories/users_repository.dart';
import 'package:memories/view_models/auth/session_notifier.dart';
import 'package:memories/view_models/users/my_profile_view_model.dart';

import '../../views/app_router_test.dart' show FakeSessionNotifier;
import 'users_fakes.dart';

void main() {
  late FakeUsersRepository repository;

  ProviderContainer buildContainer(SessionStatus session) =>
      ProviderContainer.test(
        overrides: [
          usersRepositoryProvider.overrideWithValue(repository),
          sessionProvider.overrideWith(() => FakeSessionNotifier(session)),
        ],
      );

  void setSession(ProviderContainer container, SessionStatus status) =>
      (container.read(sessionProvider.notifier) as FakeSessionNotifier).emit(
        status,
      );

  setUp(() => repository = FakeUsersRepository());

  test('sin sesión vale null y no pide nada', () async {
    final container = buildContainer(SessionStatus.signedOut);

    expect(await container.read(myProfileProvider.future), isNull);
    expect(repository.calls, 0);
  });

  test('mientras se comprueba la sesión tampoco pide nada', () async {
    final container = buildContainer(SessionStatus.checking);

    expect(await container.read(myProfileProvider.future), isNull);
    expect(repository.calls, 0);
  });

  test('con sesión pide el perfil una sola vez', () async {
    final container = buildContainer(SessionStatus.signedIn);
    container.listen(myProfileProvider, (_, _) {});

    expect(await container.read(myProfileProvider.future), ana);
    expect(await container.read(myProfileProvider.future), ana);
    expect(repository.calls, 1);
  });

  test('cerrar sesión y entrar con otra cuenta muestra la nueva', () async {
    final container = buildContainer(SessionStatus.signedIn);
    container.listen(myProfileProvider, (_, _) {});
    expect(await container.read(myProfileProvider.future), ana);

    setSession(container, SessionStatus.signedOut);
    expect(await container.read(myProfileProvider.future), isNull);

    repository.onMyProfile = () async => luis;
    setSession(container, SessionStatus.signedIn);

    expect(await container.read(myProfileProvider.future), luis);
    expect(repository.calls, 2);
  });

  test('si la cuenta anterior responde tarde, no pisa a la nueva', () async {
    final slowAna = Completer<Profile>();
    repository.onMyProfile = () => slowAna.future;
    final container = buildContainer(SessionStatus.signedIn);
    container.listen(myProfileProvider, (_, _) {});

    setSession(container, SessionStatus.signedOut);
    repository.onMyProfile = () async => luis;
    setSession(container, SessionStatus.signedIn);
    expect(await container.read(myProfileProvider.future), luis);

    slowAna.complete(ana);
    await pumpEventQueue();
    expect(container.read(myProfileProvider).value, luis);
  });

  test('un error queda como AsyncError, sin reintentos solos', () async {
    repository.onMyProfile = () async =>
        throw const ApiError(ApiErrorCode.network);
    final container = buildContainer(SessionStatus.signedIn);
    container.listen(myProfileProvider, (_, _) {});

    await expectLater(
      container.read(myProfileProvider.future),
      throwsA(isA<ApiError>()),
    );
    await pumpEventQueue();

    expect(container.read(myProfileProvider).hasError, isTrue);
    expect(repository.calls, 1);
  });

  test('retry vuelve a pedir el perfil', () async {
    repository.onMyProfile = () async =>
        throw const ApiError(ApiErrorCode.network);
    final container = buildContainer(SessionStatus.signedIn);
    container.listen(myProfileProvider, (_, _) {});
    await expectLater(
      container.read(myProfileProvider.future),
      throwsA(isA<ApiError>()),
    );

    repository.onMyProfile = () async => ana;
    container.read(myProfileProvider.notifier).retry();

    expect(await container.read(myProfileProvider.future), ana);
    expect(repository.calls, 2);
  });
}
