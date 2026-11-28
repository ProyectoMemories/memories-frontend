import 'package:flutter_test/flutter_test.dart';
import 'package:memories/view_models/auth/session_notifier.dart';
import 'package:memories/views/app_router.dart';

import '../../view_models/users/my_profile_view_model_test.dart' show luis;
import '../signed_in_app.dart';

void main() {
  testWidgets('Perfil muestra quién soy y Cerrar sesión', (tester) async {
    final app = await SignedInApp.pump(tester);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(app.location, AppRoutes.profile);
    expect(find.text('Ana Paz'), findsOneWidget);
    expect(find.text('@ana.paz · ana@ejemplo.pe'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
    // Inicio ya pidió el perfil: Perfil no lo vuelve a pedir.
    expect(app.users.calls, 1);
  });

  testWidgets('al entrar con otra cuenta se ven sus datos (RNF-02)', (
    tester,
  ) async {
    final app = await SignedInApp.pump(tester);
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Ana Paz'), findsOneWidget);

    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    app.users.onMyProfile = () async => luis;
    await app.container
        .read(sessionProvider.notifier)
        .logIn(identifier: 'luis', password: 'clave-de-prueba');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Luis Ríos'), findsOneWidget);
    expect(find.text('Ana Paz'), findsNothing);
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
