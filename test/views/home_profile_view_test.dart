import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/repositories/auth_repository.dart';
import 'package:memories/repositories/session/token_store.dart';
import 'package:memories/views/app_router.dart';
import 'package:memories/views/home_view.dart';
import 'package:memories/views/theme/app_theme.dart';

import '../repositories/fake_http_adapter.dart';
import '../view_models/auth/session_notifier_test.dart' show FakeAuthRepository;

void main() {
  group('greetingFor', () {
    test('saluda según la hora del día', () {
      expect(greetingFor(DateTime(2026, 11, 26, 6)), 'Buenos días');
      expect(greetingFor(DateTime(2026, 11, 26, 11, 59)), 'Buenos días');
      expect(greetingFor(DateTime(2026, 11, 26, 12)), 'Buenas tardes');
      expect(greetingFor(DateTime(2026, 11, 26, 18, 59)), 'Buenas tardes');
      expect(greetingFor(DateTime(2026, 11, 26, 19)), 'Buenas noches');
      expect(greetingFor(DateTime(2026, 11, 26, 2)), 'Buenas noches');
    });
  });

  group('Inicio y Perfil con sesión', () {
    late FakeAuthRepository repository;
    late int logouts;

    Future<ProviderContainer> pumpApp(WidgetTester tester) async {
      logouts = 0;
      repository = FakeAuthRepository()..onLogout = () async => logouts++;
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          tokenStoreProvider.overrideWithValue(
            InMemoryTokenStore(const SessionTokens(accessToken: 'acceso')),
          ),
        ],
      );
      addTearDown(container.dispose);
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
      return container;
    }

    String location(ProviderContainer container) => container
        .read(routerProvider)
        .routerDelegate
        .currentConfiguration
        .uri
        .path;

    testWidgets('Inicio muestra el título y la barra inferior', (tester) async {
      final container = await pumpApp(tester);

      expect(location(container), AppRoutes.home);
      expect(find.text('Tus álbumes'), findsOneWidget);
      expect(find.text('Inicio'), findsOneWidget);
      expect(find.text('Álbum'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
    });

    testWidgets('crear álbum todavía no está disponible', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpApp(tester);

      final button = find.bySemanticsLabel(RegExp('^Crear álbum'));
      expect(button, findsOneWidget);
      expect(
        tester.getSemantics(button),
        isSemantics(isButton: true, isEnabled: false),
      );
      handle.dispose();
    });

    testWidgets('la barra lleva a Perfil y de vuelta a Inicio', (tester) async {
      final container = await pumpApp(tester);

      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();
      expect(location(container), AppRoutes.profile);
      expect(find.text('Cerrar sesión'), findsOneWidget);

      await tester.tap(find.text('Inicio'));
      await tester.pumpAndSettle();
      expect(location(container), AppRoutes.home);
    });

    testWidgets('Cerrar sesión revoca la sesión y vuelve al login', (
      tester,
    ) async {
      final container = await pumpApp(tester);
      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cerrar sesión'));
      await tester.pumpAndSettle();

      expect(logouts, 1);
      expect(location(container), AppRoutes.login);
      expect(find.text('Entrar'), findsOneWidget);
    });
  });
}
