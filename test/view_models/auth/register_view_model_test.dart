import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/repositories/api_error.dart';
import 'package:memories/repositories/auth_repository.dart';
import 'package:memories/view_models/auth/register_view_model.dart';

import 'session_notifier_test.dart' show FakeAuthRepository;

void main() {
  late FakeAuthRepository repository;
  late ProviderContainer container;
  late List<Registration> registrations;

  // Hoy, para todos los tests: 27 de noviembre de 2026.
  final today = DateTime(2026, 11, 27, 10);

  setUp(() {
    repository = FakeAuthRepository();
    registrations = [];
    repository.onRegister = (registration) async =>
        registrations.add(registration);
    container = ProviderContainer.test(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        todayProvider.overrideWithValue(() => today),
      ],
    );
    // autoDispose: los dos pasos lo escuchan mientras están abiertos.
    container.listen(registerViewModelProvider, (_, _) {});
  });

  RegisterViewModel viewModel() =>
      container.read(registerViewModelProvider.notifier);
  RegisterState state() => container.read(registerViewModelProvider);

  NextStepResult fillStep1({
    String firstName = ' Ana ',
    String paternalSurname = 'López',
    String maternalSurname = '',
    DateTime? birthDate,
    bool withoutBirthDate = false,
  }) => viewModel().next(
    firstName: firstName,
    paternalSurname: paternalSurname,
    maternalSurname: maternalSurname,
    birthDate: withoutBirthDate ? null : birthDate ?? DateTime(2000, 5, 1),
  );

  Future<SubmitResult> submitStep2({
    String username = 'ana.lopez',
    String email = 'ana@ejemplo.pe',
    String password = 'clave-segura',
    bool acceptsPrivacyPolicy = true,
  }) => viewModel().submit(
    username: username,
    email: email,
    password: password,
    acceptsPrivacyPolicy: acceptsPrivacyPolicy,
  );

  group('paso 1', () {
    test('completo: guarda los datos sin espacios y pasa al paso 2', () {
      expect(fillStep1(maternalSurname: '  '), NextStepResult.ready);

      final data = state().personalData!;
      expect(data.firstName, 'Ana');
      expect(data.paternalSurname, 'López');
      expect(data.maternalSurname, isNull);
      expect(state().errors, isEmpty);
    });

    test('marca cada obligatorio que falta', () {
      expect(
        fillStep1(firstName: ' ', paternalSurname: '', withoutBirthDate: true),
        NextStepResult.incomplete,
      );

      expect(state().errors, {
        RegisterField.firstName: 'Escribe tu nombre.',
        RegisterField.paternalSurname: 'Escribe tu apellido paterno.',
        RegisterField.birthDate: 'Elige tu fecha de nacimiento.',
      });
      expect(state().personalData, isNull);
    });

    test('un nombre de más de 100 caracteres se marca', () {
      fillStep1(maternalSurname: 'a' * 101);
      expect(
        state().errors[RegisterField.maternalSurname],
        'Usa hasta 100 caracteres.',
      );
    });

    test('con 14 años cumplidos hoy, puede seguir (RN-08)', () {
      expect(
        fillStep1(birthDate: DateTime(2012, 11, 27)),
        NextStepResult.ready,
      );
    });

    test('si cumple 14 mañana, es menor: no guarda nada', () {
      expect(
        fillStep1(birthDate: DateTime(2012, 11, 28)),
        NextStepResult.underage,
      );
      expect(state().personalData, isNull);
      expect(registrations, isEmpty);
    });
  });

  group('paso 2', () {
    setUp(() => fillStep1());

    test('crea la cuenta con los datos de los dos pasos', () async {
      expect(
        await submitStep2(username: ' ana.lopez ', email: ' ana@ejemplo.pe '),
        SubmitResult.registered,
      );

      final sent = registrations.single;
      expect(sent.username, 'ana.lopez');
      expect(sent.email, 'ana@ejemplo.pe');
      expect(sent.password, 'clave-segura');
      expect(sent.firstName, 'Ana');
      expect(sent.paternalSurname, 'López');
      expect(sent.birthDate, DateTime(2000, 5, 1));
      expect(sent.acceptsPrivacyPolicy, isTrue);
    });

    test('sin la casilla no envía nada y pide marcarla', () async {
      expect(
        await submitStep2(acceptsPrivacyPolicy: false),
        SubmitResult.failed,
      );
      expect(
        state().errors[RegisterField.privacyPolicy],
        'Acepta la política de privacidad para continuar.',
      );
      expect(registrations, isEmpty);
      expect(state().personalData, isNotNull);
    });

    test('revisa usuario, correo y contraseña antes de enviar', () async {
      await submitStep2(
        username: 'ana..lopez',
        email: 'ana@',
        password: '1234',
      );

      expect(state().errors, {
        RegisterField.username: "No puede tener dos '.' seguidos.",
        RegisterField.email: 'Escribe un correo válido.',
        RegisterField.password: 'Usa de 8 a 64 caracteres.',
      });
      expect(registrations, isEmpty);
    });

    test('la contraseña se cuenta por caracteres, no por UTF-16', () async {
      // 8 emojis: 16 unidades UTF-16, pero 8 caracteres para la API.
      await submitStep2(password: '😀' * 8);
      expect(state().errors, isEmpty);
    });

    Future<RegisterState> afterApiError(ApiError error) async {
      repository.onRegister = (_) async => throw error;
      expect(await submitStep2(), SubmitResult.failed);
      return state();
    }

    test('usuario o correo en uso: error en ese campo', () async {
      expect(
        (await afterApiError(const ApiError(ApiErrorCode.usernameTaken)))
            .errors,
        {RegisterField.username: 'Ese nombre de usuario ya existe.'},
      );
      expect(
        (await afterApiError(const ApiError(ApiErrorCode.emailTaken))).errors,
        {RegisterField.email: 'Ese correo ya tiene una cuenta.'},
      );
    });

    test('contraseña común: pide elegir otra', () async {
      expect(
        (await afterApiError(const ApiError(ApiErrorCode.passwordTooCommon)))
            .errors,
        {RegisterField.password: 'Es una contraseña muy común; elige otra.'},
      );
    });

    test('validation_error del correo: lo marca en el campo', () async {
      expect(
        (await afterApiError(
          const ApiError(ApiErrorCode.validationError, fields: {'email'}),
        )).errors,
        {RegisterField.email: 'Escribe un correo válido.'},
      );
    });

    test('sin conexión: mensaje general y conserva el paso 1', () async {
      final result = await afterApiError(const ApiError(ApiErrorCode.network));
      expect(
        result.errorMessage,
        'No pudimos conectar. Revisa tu conexión e inténtalo de nuevo.',
      );
      expect(result.personalData, isNotNull);
      expect(result.isSubmitting, isFalse);
    });

    test('la API dice underage: va a Menor de 14 y borra los datos', () async {
      repository.onRegister = (_) async =>
          throw const ApiError(ApiErrorCode.underage);
      expect(await submitStep2(), SubmitResult.underage);
      expect(state().personalData, isNull);
    });

    test('sin el paso 1 no envía nada', () async {
      container.invalidate(registerViewModelProvider);
      expect(await submitStep2(), SubmitResult.failed);
      expect(registrations, isEmpty);
    });
  });

  test('un segundo toque mientras se envía no crea otra cuenta', () async {
    fillStep1();
    final answer = Completer<void>();
    repository.onRegister = (registration) {
      registrations.add(registration);
      return answer.future;
    };

    final first = submitStep2();
    expect(await submitStep2(), SubmitResult.failed);
    answer.complete();

    expect(await first, SubmitResult.registered);
    expect(registrations, hasLength(1));
  });
}
