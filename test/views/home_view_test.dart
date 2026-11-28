import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:memories/repositories/api_error.dart';
import 'package:memories/repositories/users_repository.dart';
import 'package:memories/views/app_router.dart';
import 'package:memories/views/home_view.dart';

import '../view_models/users/my_profile_view_model_test.dart';
import 'signed_in_app.dart';

/// El saludo sin nombre, sea la hora que sea.
final greetingAlone = RegExp(r'^Buen(os días|as tardes|as noches)$');

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

  group('saludo', () {
    testWidgets('con el perfil, dice el nombre', (tester) async {
      await SignedInApp.pump(tester);

      expect(find.textContaining(RegExp(r'^Buen.*, Ana$')), findsOneWidget);
    });

    testWidgets('mientras carga, dice solo el saludo', (tester) async {
      final pending = Completer<Profile>();
      await SignedInApp.pump(
        tester,
        users: FakeUsersRepository()..onMyProfile = () => pending.future,
      );

      expect(find.textContaining(greetingAlone), findsOneWidget);
      expect(find.textContaining('Ana'), findsNothing);
    });

    testWidgets('si falla, dice solo el saludo y ningún error', (tester) async {
      await SignedInApp.pump(
        tester,
        users: FakeUsersRepository()
          ..onMyProfile = () async =>
              throw const ApiError(ApiErrorCode.network),
      );

      expect(find.textContaining(greetingAlone), findsOneWidget);
      expect(find.textContaining('No pudimos'), findsNothing);
    });
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
