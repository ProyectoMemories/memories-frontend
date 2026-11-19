import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/main.dart';

void main() {
  testWidgets('la app arranca y muestra la pantalla de inicio', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MemoriesApp()));

    expect(find.text('Memories'), findsOneWidget);
  });
}
