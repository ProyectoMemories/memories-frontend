import 'package:flutter_test/flutter_test.dart';
import 'package:memories/views/app_router.dart';

import '../signed_in_app.dart';

void main() {
  testWidgets('Perfil muestra Cerrar sesión', (tester) async {
    final app = await SignedInApp.pump(tester);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(app.location, AppRoutes.profile);
    expect(find.text('Cerrar sesión'), findsOneWidget);
  });

  testWidgets('Cerrar sesión revoca la sesión y vuelve al login', (
    tester,
  ) async {
    final app = await SignedInApp.pump(tester);
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(app.logouts, 1);
    expect(app.location, AppRoutes.login);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
