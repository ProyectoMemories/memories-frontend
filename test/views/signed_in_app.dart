import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/repositories/auth_repository.dart';
import 'package:memories/repositories/session/token_store.dart';
import 'package:memories/repositories/users_repository.dart';
import 'package:memories/views/app_router.dart';
import 'package:memories/views/theme/app_theme.dart';

import '../repositories/fake_http_adapter.dart';
import '../view_models/auth/session_notifier_test.dart' show FakeAuthRepository;
import '../view_models/users/my_profile_view_model_test.dart'
    show FakeUsersRepository;

/// La app completa con una sesión ya guardada, un repositorio de auth falso
/// que cuenta los logout y uno de users que responde con [users] (por
/// defecto, el perfil de Ana).
class SignedInApp {
  SignedInApp._(this.container, this.repository, this.users);

  final ProviderContainer container;
  final FakeAuthRepository repository;
  final FakeUsersRepository users;
  int logouts = 0;

  static Future<SignedInApp> pump(
    WidgetTester tester, {
    FakeUsersRepository? users,
  }) async {
    final repository = FakeAuthRepository();
    final usersRepository = users ?? FakeUsersRepository();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        usersRepositoryProvider.overrideWithValue(usersRepository),
        tokenStoreProvider.overrideWithValue(
          InMemoryTokenStore(const SessionTokens(accessToken: 'acceso')),
        ),
      ],
    );
    addTearDown(container.dispose);
    final app = SignedInApp._(container, repository, usersRepository);
    repository.onLogout = () async => app.logouts++;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) => MaterialApp.router(
            theme: buildAppTheme(),
            routerConfig: ref.watch(routerProvider),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return app;
  }

  String get location => container
      .read(routerProvider)
      .routerDelegate
      .currentConfiguration
      .uri
      .path;
}
