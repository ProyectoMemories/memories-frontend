import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/view_models/auth/session_notifier.dart';
import 'package:memories/views/app_router.dart';

/// SessionNotifier con el estado que pida el test, sin tocar la API.
class FakeSessionNotifier extends SessionNotifier {
  FakeSessionNotifier(this._initial);

  final SessionStatus _initial;

  @override
  SessionStatus build() => _initial;

  void emit(SessionStatus status) => state = status;
}

void main() {
  group('redirectFor', () {
    String? go(SessionStatus status, String location) =>
        redirectFor(status, Uri.parse(location));

    test(
      'comprobando: espera en la pantalla de carga y recuerda el destino',
      () {
        expect(go(SessionStatus.checking, '/'), isNull);
        expect(go(SessionStatus.checking, '/profile'), '/?from=%2Fprofile');
      },
    );

    test('sin sesión: solo rutas de auth; lo demás va a /login', () {
      expect(go(SessionStatus.signedOut, '/home'), AppRoutes.login);
      expect(go(SessionStatus.signedOut, '/profile'), AppRoutes.login);
      expect(go(SessionStatus.signedOut, '/login'), isNull);
    });

    test('con sesión: las rutas de auth llevan a /home', () {
      expect(go(SessionStatus.signedIn, '/login'), AppRoutes.home);
      expect(go(SessionStatus.signedIn, '/register'), AppRoutes.home);
      expect(go(SessionStatus.signedIn, '/check-email'), AppRoutes.home);
      expect(go(SessionStatus.signedIn, '/home'), isNull);
      expect(go(SessionStatus.signedIn, '/profile'), isNull);
    });

    test('al terminar de comprobar, sigue al destino que recordó', () {
      expect(go(SessionStatus.signedIn, '/?from=%2Fprofile'), '/profile');
      expect(go(SessionStatus.signedIn, '/'), AppRoutes.home);
      expect(go(SessionStatus.signedOut, '/'), AppRoutes.login);
      // Sin sesión, un destino privado no sirve: va a iniciar sesión.
      expect(go(SessionStatus.signedOut, '/?from=%2Fprofile'), AppRoutes.login);
    });

    test('el enlace de verificación se abre con o sin sesión (design §7)', () {
      expect(go(SessionStatus.signedIn, '/verify-email?token=abc'), isNull);
      expect(go(SessionStatus.signedOut, '/verify-email?token=abc'), isNull);
      // Al abrir la app desde el enlace, sigue al enlace al terminar de
      // comprobar la sesión, con o sin sesión.
      const fromLink = '/?from=%2Fverify-email%3Ftoken%3Dabc';
      expect(go(SessionStatus.signedIn, fromLink), '/verify-email?token=abc');
      expect(go(SessionStatus.signedOut, fromLink), '/verify-email?token=abc');
    });

    test('un destino que apunta a la carga se ignora (sin bucles)', () {
      expect(
        go(SessionStatus.signedIn, '/?from=%2F%3Ffrom%3D%252Fprofile'),
        AppRoutes.home,
      );
    });

    test('un destino recordado de otro sitio se ignora', () {
      expect(
        go(SessionStatus.signedIn, '/?from=https%3A%2F%2Fotro.sitio%2Fx'),
        AppRoutes.home,
      );
    });
  });

  group('routerProvider', () {
    late FakeSessionNotifier session;

    Future<ProviderContainer> pumpRouter(
      WidgetTester tester,
      SessionStatus initial,
    ) async {
      session = FakeSessionNotifier(initial);
      final container = ProviderContainer(
        overrides: [sessionProvider.overrideWith(() => session)],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) =>
                MaterialApp.router(routerConfig: ref.watch(routerProvider)),
          ),
        ),
      );
      // La rueda de carga gira sin parar: con ella, pumpAndSettle no termina.
      if (initial == SessionStatus.checking) {
        await tester.pump();
      } else {
        await tester.pumpAndSettle();
      }
      return container;
    }

    String location(ProviderContainer container) => container
        .read(routerProvider)
        .routerDelegate
        .currentConfiguration
        .uri
        .toString();

    testWidgets('mientras comprueba muestra la carga y luego el login', (
      tester,
    ) async {
      final container = await pumpRouter(tester, SessionStatus.checking);
      expect(location(container), AppRoutes.splash);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      session.emit(SessionStatus.signedOut);
      await tester.pumpAndSettle();

      expect(location(container), AppRoutes.login);
    });

    testWidgets('al iniciar sesión pasa a Inicio y al salir vuelve al login', (
      tester,
    ) async {
      final container = await pumpRouter(tester, SessionStatus.signedOut);

      session.emit(SessionStatus.signedIn);
      await tester.pumpAndSettle();
      expect(location(container), AppRoutes.home);

      session.emit(SessionStatus.signedOut);
      await tester.pumpAndSettle();
      expect(location(container), AppRoutes.login);
    });

    testWidgets('una ruta que no existe muestra "no encontrado" en español', (
      tester,
    ) async {
      final container = await pumpRouter(tester, SessionStatus.signedIn);

      container.read(routerProvider).go('/no-existe');
      await tester.pumpAndSettle();

      expect(find.text('No encontramos esta página.'), findsOneWidget);
      expect(find.text('Ir a Inicio'), findsOneWidget);
    });

    testWidgets('con sesión, ir a /login lleva a Inicio', (tester) async {
      final container = await pumpRouter(tester, SessionStatus.signedIn);

      container.read(routerProvider).go(AppRoutes.login);
      await tester.pumpAndSettle();

      expect(location(container), AppRoutes.home);
    });
  });
}
