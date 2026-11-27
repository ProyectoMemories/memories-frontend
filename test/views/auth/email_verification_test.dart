import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/repositories/api_error.dart';
import 'package:memories/view_models/auth/session_notifier.dart';
import 'package:memories/views/app_router.dart';

import '../signed_out_app.dart';

void main() {
  group('Revisa tu correo', () {
    testWidgets('con el correo conocido, Reenviar avisa "Correo reenviado"', (
      tester,
    ) async {
      final app = await SignedOutApp.pump(tester);
      final resent = <String>[];
      app.repository.onResendVerification = (email) async => resent.add(email);
      app.router.go(AppRoutes.checkEmail, extra: 'ana@ejemplo.pe');
      await tester.pumpAndSettle();

      expect(
        find.textContaining('ana@ejemplo.pe', findRichText: true),
        findsOneWidget,
      );
      expect(textFieldLabeled('Correo'), findsNothing);
      expect(
        find.textContaining('vence en 24 horas', findRichText: true),
        findsOneWidget,
      );

      await tester.tap(find.text('Reenviar correo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(resent, ['ana@ejemplo.pe']);
      expect(find.text('Correo reenviado'), findsOneWidget);
    });

    testWidgets('sin el correo, lo pide para reenviar', (tester) async {
      final app = await SignedOutApp.pump(tester);
      final resent = <String>[];
      app.repository.onResendVerification = (email) async => resent.add(email);
      app.router.go(AppRoutes.checkEmail);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reenviar correo'));
      await tester.pumpAndSettle();
      expect(find.text('Escribe tu correo.'), findsOneWidget);
      expect(resent, isEmpty);

      await tester.enterText(textFieldLabeled('Correo'), 'ana@ejemplo.pe');
      await tester.tap(find.text('Reenviar correo'));
      await tester.pump();
      expect(resent, ['ana@ejemplo.pe']);
    });

    testWidgets('el botón atrás de Android lleva al login', (tester) async {
      final app = await SignedOutApp.pump(tester);
      app.router.go(AppRoutes.checkEmail);
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(app.location, AppRoutes.login);
    });

    testWidgets('Ya lo verifiqué lleva a Iniciar sesión', (tester) async {
      final app = await SignedOutApp.pump(tester);
      app.router.go(AppRoutes.checkEmail);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ya lo verifiqué'));
      await tester.pumpAndSettle();

      expect(app.location, AppRoutes.login);
    });
  });

  group('login con una cuenta sin verificar (HU-01)', () {
    Future<SignedOutApp> logInUnverified(
      WidgetTester tester,
      String identifier,
    ) async {
      final app = await SignedOutApp.pump(tester);
      app.repository.onLogin = () async =>
          throw const ApiError(ApiErrorCode.emailNotVerified);
      await tester.enterText(
        textFieldLabeled('Correo o nombre de usuario'),
        identifier,
      );
      await tester.enterText(textFieldLabeled('Contraseña'), 'clave-segura');
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pumpAndSettle();
      return app;
    }

    testWidgets('con correo: Revisa tu correo lo muestra', (tester) async {
      final app = await logInUnverified(tester, 'ana@ejemplo.pe');

      expect(app.location, AppRoutes.checkEmail);
      expect(
        find.textContaining('ana@ejemplo.pe', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('con nombre de usuario: pide el correo', (tester) async {
      final app = await logInUnverified(tester, 'ana');

      expect(app.location, AppRoutes.checkEmail);
      expect(textFieldLabeled('Correo'), findsOneWidget);
    });
  });

  group('/verify-email', () {
    testWidgets('verifica la cuenta y ofrece iniciar sesión', (tester) async {
      final app = await SignedOutApp.pump(tester);
      final tokens = <String>[];
      app.repository.onVerifyEmail = (token) async => tokens.add(token);

      app.router.go('${AppRoutes.verifyEmail}?token=abc.123');
      await tester.pumpAndSettle();

      expect(tokens, ['abc.123']);
      expect(find.text('Correo verificado'), findsOneWidget);

      await tester.tap(find.text('Iniciar sesión'));
      await tester.pumpAndSettle();
      expect(app.location, AppRoutes.login);
    });

    testWidgets('enlace vencido: ofrece pedir otro', (tester) async {
      final app = await SignedOutApp.pump(tester);
      app.repository.onVerifyEmail = (_) async =>
          throw const ApiError(ApiErrorCode.expiredToken);

      app.router.go('${AppRoutes.verifyEmail}?token=viejo');
      await tester.pumpAndSettle();

      expect(find.text('El enlace venció'), findsOneWidget);
      await tester.tap(find.text('Pedir otro enlace'));
      await tester.pumpAndSettle();
      expect(app.location, AppRoutes.checkEmail);
    });

    testWidgets('sin conexión: Reintentar vuelve a verificar', (tester) async {
      final app = await SignedOutApp.pump(tester);
      app.repository.onVerifyEmail = (_) async =>
          throw const ApiError(ApiErrorCode.network);

      app.router.go('${AppRoutes.verifyEmail}?token=abc');
      await tester.pumpAndSettle();
      expect(find.text('No pudimos verificar'), findsOneWidget);

      app.repository.onVerifyEmail = (_) async {};
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(find.text('Correo verificado'), findsOneWidget);
    });
  });

  test('con sesión, el enlace de verificación lleva a Inicio sin llamar a '
      'la API (design §7)', () {
    expect(
      redirectFor(
        SessionStatus.signedIn,
        Uri.parse('${AppRoutes.verifyEmail}?token=abc'),
      ),
      AppRoutes.home,
    );
  });
}
