import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/views/theme/app_theme.dart';
import 'package:memories/views/widgets/app_buttons.dart';
import 'package:memories/views/widgets/app_password_field.dart';
import 'package:memories/views/widgets/app_text_field.dart';
import 'package:memories/views/widgets/app_toast.dart';

Future<void> pumpInApp(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(24), child: child),
      ),
    ),
  );
}

void main() {
  group('AppTextField', () {
    testWidgets('muestra la etiqueta en mayúsculas y la anuncia', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpInApp(
        tester,
        AppTextField(
          label: 'Correo o nombre de usuario',
          controller: TextEditingController(),
          hint: 'tu@correo.com',
        ),
      );

      expect(find.text('CORREO O NOMBRE DE USUARIO'), findsOneWidget);
      // El lector anuncia primero la etiqueta y luego el texto de ejemplo.
      expect(
        find.bySemanticsLabel(RegExp('^Correo o nombre de usuario')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('escribe en el controlador', (tester) async {
      final controller = TextEditingController();
      await pumpInApp(
        tester,
        AppTextField(label: 'Correo', controller: controller),
      );

      await tester.enterText(find.byType(TextField), 'ana@ejemplo.pe');

      expect(controller.text, 'ana@ejemplo.pe');
    });

    testWidgets('muestra el error debajo del campo', (tester) async {
      await pumpInApp(
        tester,
        AppTextField(
          label: 'Correo',
          controller: TextEditingController(),
          errorText: 'Ese correo ya tiene una cuenta.',
        ),
      );

      expect(find.text('Ese correo ya tiene una cuenta.'), findsOneWidget);
    });
  });

  group('AppPasswordField', () {
    testWidgets('oculta la contraseña y el botón la muestra', (tester) async {
      await pumpInApp(
        tester,
        AppPasswordField(
          label: 'Contraseña',
          controller: TextEditingController(text: 'secreta'),
        ),
      );
      bool obscured() =>
          tester.widget<TextField>(find.byType(TextField)).obscureText;

      expect(obscured(), isTrue);
      await tester.tap(find.byTooltip('Mostrar contraseña'));
      await tester.pump();
      expect(obscured(), isFalse);

      await tester.tap(find.byTooltip('Ocultar contraseña'));
      await tester.pump();
      expect(obscured(), isTrue);
    });
  });

  group('PrimaryButton', () {
    testWidgets('al tocarlo llama a onPressed', (tester) async {
      var taps = 0;
      await pumpInApp(
        tester,
        PrimaryButton(label: 'Entrar', onPressed: () => taps++),
      );

      await tester.tap(find.text('Entrar'));

      expect(taps, 1);
    });

    testWidgets('cargando: muestra que espera y no acepta otro toque', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await pumpInApp(
        tester,
        PrimaryButton(
          label: 'Entrar',
          onPressed: () => taps++,
          isLoading: true,
        ),
      );

      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);

      expect(taps, 0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.bySemanticsLabel('Entrar, cargando'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('mide 54 px de alto, como en el mockup', (tester) async {
      await pumpInApp(tester, PrimaryButton(label: 'Entrar', onPressed: () {}));

      expect(tester.getSize(find.byType(FilledButton)).height, 54);
    });
  });

  group('SecondaryButton', () {
    testWidgets('es el botón con borde y llama a onPressed', (tester) async {
      var taps = 0;
      await pumpInApp(
        tester,
        SecondaryButton(label: 'Crear cuenta', onPressed: () => taps++),
      );

      await tester.tap(find.text('Crear cuenta'));

      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(taps, 1);
    });
  });

  group('showAppToast', () {
    testWidgets('muestra el aviso abajo con su texto', (tester) async {
      await pumpInApp(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showAppToast(context, 'Correo reenviado'),
            child: const Text('avisar'),
          ),
        ),
      );

      await tester.tap(find.text('avisar'));
      await tester.pump();

      expect(find.text('Correo reenviado'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
