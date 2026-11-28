import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/main.dart';
import 'package:memories/repositories/auth_repository.dart';
import 'package:memories/repositories/session/token_store.dart';
import 'package:memories/repositories/users_repository.dart';
import 'package:memories/view_models/auth/register_view_model.dart';
import 'package:memories/views/app_router.dart';
import 'package:memories/views/widgets/app_text_field.dart';

import '../repositories/fake_http_adapter.dart';
import '../view_models/auth/session_notifier_test.dart' show FakeAuthRepository;
import '../view_models/users/my_profile_view_model_test.dart'
    show FakeUsersRepository;

/// La app completa (con su tema, idioma y router) sin sesión, con un
/// repositorio falso y "hoy" fijo en el 27 de noviembre de 2026.
class SignedOutApp {
  SignedOutApp._(this.container, this.repository);

  final ProviderContainer container;
  final FakeAuthRepository repository;

  static final today = DateTime(2026, 11, 27, 10);

  static Future<SignedOutApp> pump(WidgetTester tester) async {
    // Pantalla de teléfono, como el mockup (390 × 844).
    tester.view
      ..physicalSize = const Size(390, 844) * 3
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final repository = FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
        todayProvider.overrideWithValue(() => today),
        // Al entrar, Inicio pide el perfil: sin esto saldría a la red.
        usersRepositoryProvider.overrideWithValue(FakeUsersRepository()),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MemoriesApp(),
      ),
    );
    await tester.pumpAndSettle();
    return SignedOutApp._(container, repository);
  }

  GoRouterLike get router => GoRouterLike(container);

  String get location => router.uri.path;
}

/// Atajos sobre el router de la app.
class GoRouterLike {
  GoRouterLike(this._container);

  final ProviderContainer _container;

  Uri get uri =>
      _container.read(routerProvider).routerDelegate.currentConfiguration.uri;

  void go(String location, {Object? extra}) =>
      _container.read(routerProvider).go(location, extra: extra);
}

/// El TextField de un [AppTextField], buscado por su etiqueta.
Finder textFieldLabeled(String label) => find.descendant(
  of: find.widgetWithText(AppTextField, label.toUpperCase()),
  matching: find.byType(TextField),
);
