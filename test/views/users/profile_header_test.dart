import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/repositories/api_error.dart';
import 'package:memories/repositories/users_repository.dart';
import 'package:memories/view_models/auth/session_notifier.dart';
import 'package:memories/views/theme/app_theme.dart';
import 'package:memories/views/users/profile_header.dart';

import '../../view_models/users/my_profile_view_model_test.dart';
import '../app_router_test.dart' show FakeSessionNotifier;

void main() {
  late FakeUsersRepository repository;

  Future<void> pumpHeader(WidgetTester tester, {double width = 390}) async {
    tester.view
      ..physicalSize = Size(width, 844) * 3
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          usersRepositoryProvider.overrideWithValue(repository),
          sessionProvider.overrideWith(
            () => FakeSessionNotifier(SessionStatus.signedIn),
          ),
        ],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const Scaffold(body: ProfileHeader()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() => repository = FakeUsersRepository());

  testWidgets('muestra iniciales, nombre, usuario y correo', (tester) async {
    await pumpHeader(tester);

    expect(find.text('AP'), findsOneWidget);
    expect(find.text('Ana Paz'), findsOneWidget);
    expect(find.text('@ana.paz · ana@ejemplo.pe'), findsOneWidget);
  });

  testWidgets('se lee como un bloque, sin las iniciales', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpHeader(tester);

    expect(
      find.bySemanticsLabel('Ana Paz, @ana.paz, ana@ejemplo.pe'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('AP'), findsNothing);
    handle.dispose();
  });

  testWidgets('nombres largos se cortan sin desbordar', (tester) async {
    repository = FakeUsersRepository(
      const Profile(
        firstName: 'María de los Ángeles Guadalupe',
        paternalSurname: 'Fernández-Villanueva',
        maternalSurname: null,
        username: 'maria.de.los.angeles.guadalupe',
        email: 'maria.de.los.angeles.guadalupe@un-dominio-muy-largo.com',
      ),
    );
    await pumpHeader(tester, width: 320);

    expect(tester.takeException(), isNull);
    final name = tester.widget<Text>(
      find.text('María de los Ángeles Guadalupe Fernández-Villanueva'),
    );
    expect(name.maxLines, 1);
    expect(name.overflow, TextOverflow.ellipsis);
  });

  testWidgets('mientras carga lo dice al lector de pantalla', (tester) async {
    final handle = tester.ensureSemantics();
    final pending = Completer<Profile>();
    repository.onMyProfile = () => pending.future;
    await pumpHeader(tester);

    expect(find.bySemanticsLabel('Cargando tus datos'), findsOneWidget);
    expect(find.text('Ana Paz'), findsNothing);
    handle.dispose();
  });

  testWidgets('si falla, Reintentar vuelve a pedir y muestra los datos', (
    tester,
  ) async {
    repository.onMyProfile = () async =>
        throw const ApiError(ApiErrorCode.network);
    await pumpHeader(tester);

    expect(find.text('No pudimos cargar tus datos.'), findsOneWidget);
    final retry = find.widgetWithText(TextButton, 'Reintentar');
    expect(tester.getSize(retry).height, greaterThanOrEqualTo(44));

    repository.onMyProfile = () async => ana;
    await tester.tap(retry);
    await tester.pumpAndSettle();

    expect(repository.calls, 2);
    expect(find.text('Ana Paz'), findsOneWidget);
    expect(find.text('No pudimos cargar tus datos.'), findsNothing);
  });
}
