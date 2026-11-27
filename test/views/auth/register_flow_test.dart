import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/repositories/api_error.dart';
import 'package:memories/repositories/auth_repository.dart';
import 'package:memories/views/app_router.dart';

import '../signed_out_app.dart';

void main() {
  late SignedOutApp app;
  late List<Registration> registrations;

  Future<void> openRegister(WidgetTester tester) async {
    app = await SignedOutApp.pump(tester);
    registrations = [];
    app.repository.onRegister = (registration) async =>
        registrations.add(registration);
    final createAccount = find.widgetWithText(OutlinedButton, 'Crear cuenta');
    await tester.ensureVisible(createAccount);
    await tester.tap(createAccount);
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  /// Elige la fecha escribiéndola en el calendario de Material, en español.
  Future<void> pickBirthDate(WidgetTester tester, String date) async {
    await tester.tap(find.text('DD/MM/AAAA'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(TextField),
      ),
      date,
    );
    await tester.tap(find.text('ACEPTAR'));
    await tester.pumpAndSettle();
  }

  Future<void> fillStep1(
    WidgetTester tester, {
    String date = '01/05/2000',
  }) async {
    await tester.enterText(textFieldLabeled('Nombre'), 'Ana');
    await tester.enterText(textFieldLabeled('Apellido paterno'), 'López');
    await pickBirthDate(tester, date);
  }

  Future<void> fillStep2(WidgetTester tester) async {
    await tester.enterText(textFieldLabeled('Nombre de usuario'), 'ana.lopez');
    await tester.enterText(textFieldLabeled('Correo'), 'ana@ejemplo.pe');
    await tester.enterText(textFieldLabeled('Contraseña'), 'clave-segura');
  }

  testWidgets('Crear cuenta en el login abre el paso 1', (tester) async {
    await openRegister(tester);

    expect(app.location, AppRoutes.register);
    expect(find.text('Cuéntanos quién eres'), findsOneWidget);
    expect(find.text('PASO 1 DE 2'), findsOneWidget);
  });

  testWidgets('Siguiente sin datos marca los obligatorios', (tester) async {
    await openRegister(tester);

    await tapText(tester, 'Siguiente');

    expect(app.location, AppRoutes.register);
    expect(find.text('Escribe tu nombre.'), findsOneWidget);
    expect(find.text('Escribe tu apellido paterno.'), findsOneWidget);
    expect(find.text('Elige tu fecha de nacimiento.'), findsOneWidget);
  });

  testWidgets('del paso 2 se vuelve al paso 1 con lo escrito (HU-02)', (
    tester,
  ) async {
    await openRegister(tester);
    await fillStep1(tester);
    expect(find.text('01/05/2000'), findsOneWidget);

    await tapText(tester, 'Siguiente');
    expect(app.location, AppRoutes.registerAccess);
    expect(find.text('PASO 2 DE 2'), findsOneWidget);

    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();

    expect(app.location, AppRoutes.register);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('01/05/2000'), findsOneWidget);
  });

  testWidgets('menor de 14: no llama a la API ni guarda lo escrito', (
    tester,
  ) async {
    await openRegister(tester);
    await fillStep1(tester, date: '28/11/2012');

    await tapText(tester, 'Siguiente');

    expect(app.location, AppRoutes.registerUnderage);
    expect(find.text('Todavía no puedes crear una cuenta'), findsOneWidget);
    expect(registrations, isEmpty);

    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();
    expect(app.location, AppRoutes.register);
    expect(find.text('Ana'), findsNothing);
  });

  testWidgets('sin la casilla, Crear cuenta pide marcarla', (tester) async {
    await openRegister(tester);
    await fillStep1(tester);
    await tapText(tester, 'Siguiente');
    await fillStep2(tester);

    await tapText(tester, 'Crear cuenta');

    expect(
      find.text('Acepta la política de privacidad para continuar.'),
      findsOneWidget,
    );
    expect(registrations, isEmpty);
  });

  testWidgets('crea la cuenta y lleva a Revisa tu correo con el correo', (
    tester,
  ) async {
    await openRegister(tester);
    await fillStep1(tester);
    await tapText(tester, 'Siguiente');
    await fillStep2(tester);
    await tapText(
      tester,
      'Acepto la política de privacidad y el tratamiento '
      'de mis datos personales.',
    );

    await tapText(tester, 'Crear cuenta');

    expect(registrations.single.username, 'ana.lopez');
    expect(registrations.single.birthDate, DateTime(2000, 5, 1));
    expect(app.location, AppRoutes.checkEmail);
    expect(find.text('Revisa tu correo'), findsOneWidget);
    expect(
      find.textContaining('ana@ejemplo.pe', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('correo en uso: el error sale junto al campo', (tester) async {
    await openRegister(tester);
    app.repository.onRegister = (_) async =>
        throw const ApiError(ApiErrorCode.emailTaken);
    await fillStep1(tester);
    await tapText(tester, 'Siguiente');
    await fillStep2(tester);
    await tapText(
      tester,
      'Acepto la política de privacidad y el tratamiento '
      'de mis datos personales.',
    );

    await tapText(tester, 'Crear cuenta');

    expect(app.location, AppRoutes.registerAccess);
    expect(find.text('Ese correo ya tiene una cuenta.'), findsOneWidget);
  });

  testWidgets('abrir el paso 2 sin el paso 1 vuelve al paso 1', (tester) async {
    app = await SignedOutApp.pump(tester);

    app.router.go(AppRoutes.registerAccess);
    await tester.pumpAndSettle();

    expect(app.location, AppRoutes.register);
  });
}
