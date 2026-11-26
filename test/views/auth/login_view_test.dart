import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/repositories/api_error.dart';
import 'package:memories/repositories/auth_repository.dart';
import 'package:memories/repositories/session/token_store.dart';
import 'package:memories/views/auth/login_view.dart';
import 'package:memories/views/theme/app_theme.dart';

import '../../repositories/fake_http_adapter.dart';
import '../../view_models/auth/session_notifier_test.dart'
    show FakeAuthRepository;

/// Repositorio falso que anota con qué datos se intentó entrar.
class _LoginRecorder extends FakeAuthRepository {
  final attempts = <(String, String)>[];
  Future<void> Function() answer = () async {};

  @override
  Future<void> login({required String identifier, required String password}) {
    attempts.add((identifier, password));
    return answer();
  }
}

void main() {
  late _LoginRecorder repository;

  Future<void> pumpLogin(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
        ],
        child: MaterialApp(theme: buildAppTheme(), home: const LoginView()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder field(String label) =>
      find.bySemanticsLabel(RegExp('^${RegExp.escape(label)}'));
  Finder enterButton() => find.widgetWithText(FilledButton, 'Entrar');
  bool enterEnabled(WidgetTester tester) =>
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed != null;

  setUp(() => repository = _LoginRecorder());

  testWidgets('muestra lo del mockup: título, campos y Entrar', (tester) async {
    await pumpLogin(tester);

    expect(find.text('Memories'), findsOneWidget);
    expect(
      find.text('Tus fotos, con la historia que las hizo importantes.'),
      findsOneWidget,
    );
    expect(find.text('CORREO O NOMBRE DE USUARIO'), findsOneWidget);
    expect(find.text('CONTRASEÑA'), findsOneWidget);
    expect(enterButton(), findsOneWidget);
  });

  testWidgets('Entrar se activa con los dos campos llenos', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpLogin(tester);
    expect(enterEnabled(tester), isFalse);

    await tester.enterText(field('Correo o nombre de usuario'), 'ana');
    await tester.pump();
    expect(enterEnabled(tester), isFalse);

    await tester.enterText(field('Contraseña'), 'clave-segura');
    await tester.pump();
    expect(enterEnabled(tester), isTrue);
    handle.dispose();
  });

  testWidgets('al pulsar Entrar envía lo escrito', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpLogin(tester);

    await tester.enterText(field('Correo o nombre de usuario'), 'ana');
    await tester.enterText(field('Contraseña'), 'clave-segura');
    await tester.pump();
    await tester.tap(enterButton());
    await tester.pumpAndSettle();

    expect(repository.attempts, [('ana', 'clave-segura')]);
    handle.dispose();
  });

  testWidgets('Enter en la contraseña también envía', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpLogin(tester);

    await tester.enterText(field('Correo o nombre de usuario'), 'ana');
    await tester.enterText(field('Contraseña'), 'clave-segura');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(repository.attempts, hasLength(1));
    handle.dispose();
  });

  testWidgets('mientras espera, el botón carga y no acepta otro toque', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final answer = Completer<void>();
    repository.answer = () => answer.future;
    await pumpLogin(tester);

    await tester.enterText(field('Correo o nombre de usuario'), 'ana');
    await tester.enterText(field('Contraseña'), 'clave-segura');
    await tester.pump();
    await tester.tap(enterButton());
    await tester.pump();

    expect(find.bySemanticsLabel('Entrar, cargando'), findsOneWidget);
    await tester.tap(find.byType(FilledButton), warnIfMissed: false);
    answer.complete();
    await tester.pumpAndSettle();

    expect(repository.attempts, hasLength(1));
    handle.dispose();
  });

  testWidgets('con datos incorrectos muestra el error genérico', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    repository.answer = () async =>
        throw const ApiError(ApiErrorCode.invalidCredentials);
    await pumpLogin(tester);

    await tester.enterText(field('Correo o nombre de usuario'), 'ana');
    await tester.enterText(field('Contraseña'), 'otra-clave');
    await tester.pump();
    await tester.tap(enterButton());
    await tester.pumpAndSettle();

    expect(
      find.text('El usuario o la contraseña no son correctos.'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('cabe en un teléfono chico sin desbordarse', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpLogin(tester);

    expect(tester.takeException(), isNull);
    await tester.ensureVisible(enterButton());
    expect(enterButton(), findsOneWidget);
  });

  testWidgets('en pantallas anchas va en una columna de 420 px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpLogin(tester);

    expect(tester.getSize(enterButton()).width, lessThanOrEqualTo(420));
  });
}
