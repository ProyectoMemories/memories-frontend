import 'package:flutter_test/flutter_test.dart';
import 'package:memories/views/app_router.dart';
import 'package:memories/views/home_view.dart';

import 'signed_in_app.dart';

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

  testWidgets('Inicio muestra el título y la barra inferior', (tester) async {
    final app = await SignedInApp.pump(tester);

    expect(app.location, AppRoutes.home);
    expect(find.text('Tus álbumes'), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Álbum'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });

  testWidgets('crear álbum todavía no está disponible', (tester) async {
    final handle = tester.ensureSemantics();
    await SignedInApp.pump(tester);

    final button = find.bySemanticsLabel(RegExp('^Crear álbum'));
    expect(button, findsOneWidget);
    expect(
      tester.getSemantics(button),
      isSemantics(isButton: true, isEnabled: false),
    );
    handle.dispose();
  });

  testWidgets('la barra lleva a Perfil y de vuelta a Inicio', (tester) async {
    final app = await SignedInApp.pump(tester);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(app.location, AppRoutes.profile);

    await tester.tap(find.text('Inicio'));
    await tester.pumpAndSettle();
    expect(app.location, AppRoutes.home);
  });
}
