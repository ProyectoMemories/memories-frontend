import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/main.dart';
import 'package:memories/view_models/auth/session_notifier.dart';

import 'views/app_router_test.dart' show FakeSessionNotifier;

void main() {
  testWidgets('la app arranca y, sin sesión, muestra Iniciar sesión', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWith(
            () => FakeSessionNotifier(SessionStatus.signedOut),
          ),
        ],
        child: const MemoriesApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
