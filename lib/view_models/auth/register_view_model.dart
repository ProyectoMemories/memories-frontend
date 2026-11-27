import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/api_error.dart';
import '../../repositories/auth_repository.dart';
import 'auth_messages.dart';
import 'auth_validators.dart';

/// Campos de los dos pasos del registro, para ubicar cada error.
enum RegisterField {
  firstName,
  paternalSurname,
  maternalSurname,
  birthDate,
  username,
  email,
  password,
  privacyPolicy,
}

/// Lo que se escribió en el paso 1, ya revisado.
@immutable
class PersonalData {
  const PersonalData({
    required this.firstName,
    required this.paternalSurname,
    required this.maternalSurname,
    required this.birthDate,
  });

  final String firstName;
  final String paternalSurname;
  final String? maternalSurname;
  final DateTime birthDate;
}

/// Estado de "Registro 1" y "Registro 2" (design.md §4).
@immutable
class RegisterState {
  const RegisterState({
    this.personalData,
    this.errors = const {},
    this.isSubmitting = false,
    this.errorMessage,
  });

  /// null hasta que el paso 1 está completo: el paso 2 lo necesita.
  final PersonalData? personalData;

  /// Mensaje debajo de cada campo con error.
  final Map<RegisterField, String> errors;

  final bool isSubmitting;

  /// Error del envío que no es de un campo (sin conexión, demasiados
  /// intentos…).
  final String? errorMessage;
}

enum NextStepResult { incomplete, underage, ready }

enum SubmitResult { failed, underage, registered }

/// Hoy, para calcular la edad. Los tests lo cambian por una fecha fija.
final todayProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Compartido por los dos pasos: el paso 2 es una subruta del paso 1, así que
/// los dos lo escuchan y lo escrito sobrevive al ir y volver (HU-02).
class RegisterViewModel extends Notifier<RegisterState> {
  @override
  RegisterState build() => const RegisterState();

  /// Revisa el paso 1. Con menos de 14 años no guarda nada ni llama a la API
  /// (RN-08).
  NextStepResult next({
    required String firstName,
    required String paternalSurname,
    required String maternalSurname,
    required DateTime? birthDate,
  }) {
    final errors = {
      RegisterField.firstName: ?AuthValidators.name(
        firstName,
        emptyMessage: 'Escribe tu nombre.',
      ),
      RegisterField.paternalSurname: ?AuthValidators.name(
        paternalSurname,
        emptyMessage: 'Escribe tu apellido paterno.',
      ),
      RegisterField.maternalSurname: ?AuthValidators.name(maternalSurname),
      if (birthDate == null)
        RegisterField.birthDate: 'Elige tu fecha de nacimiento.',
    };
    if (errors.isNotEmpty || birthDate == null) {
      state = RegisterState(errors: errors);
      return NextStepResult.incomplete;
    }
    final today = ref.read(todayProvider)();
    if (AuthValidators.ageOn(birthDate, today) < AuthValidators.minimumAge) {
      state = const RegisterState();
      return NextStepResult.underage;
    }
    final maternal = maternalSurname.trim();
    state = RegisterState(
      personalData: PersonalData(
        firstName: firstName.trim(),
        paternalSurname: paternalSurname.trim(),
        maternalSurname: maternal.isEmpty ? null : maternal,
        birthDate: birthDate,
      ),
    );
    return NextStepResult.ready;
  }

  /// Crea la cuenta con los dos pasos. Si sale bien, la vista lleva a
  /// "Revisa tu correo".
  Future<SubmitResult> submit({
    required String username,
    required String email,
    required String password,
    required bool acceptsPrivacyPolicy,
  }) async {
    final personal = state.personalData;
    // El paso 2 no se muestra sin el paso 1; esto cubre un toque tardío.
    if (state.isSubmitting || personal == null) return SubmitResult.failed;
    final cleanUsername = username.trim();
    final cleanEmail = email.trim();
    final errors = {
      RegisterField.username: ?AuthValidators.username(cleanUsername),
      RegisterField.email: ?AuthValidators.email(cleanEmail),
      // La contraseña va tal cual: un espacio puede ser parte de ella.
      RegisterField.password: ?AuthValidators.newPassword(password),
      if (!acceptsPrivacyPolicy)
        RegisterField.privacyPolicy:
            'Acepta la política de privacidad para continuar.',
    };
    if (errors.isNotEmpty) {
      state = RegisterState(personalData: personal, errors: errors);
      return SubmitResult.failed;
    }

    state = RegisterState(personalData: personal, isSubmitting: true);
    try {
      await ref
          .read(authRepositoryProvider)
          .register(
            Registration(
              username: cleanUsername,
              email: cleanEmail,
              password: password,
              firstName: personal.firstName,
              paternalSurname: personal.paternalSurname,
              maternalSurname: personal.maternalSurname,
              birthDate: personal.birthDate,
              acceptsPrivacyPolicy: true,
            ),
          );
      // El estado se descarta solo al salir del registro.
      return SubmitResult.registered;
    } on ApiError catch (error) {
      if (!ref.mounted) return SubmitResult.failed;
      if (error.code == ApiErrorCode.underage) {
        state = const RegisterState();
        return SubmitResult.underage;
      }
      state = _stateFor(error, personal);
      return SubmitResult.failed;
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'memories',
          context: ErrorDescription('al crear la cuenta'),
        ),
      );
      if (ref.mounted) {
        state = RegisterState(
          personalData: personal,
          errorMessage: AuthMessages.unexpected,
        );
      }
      return SubmitResult.failed;
    }
  }

  static RegisterState _stateFor(ApiError error, PersonalData personal) {
    RegisterState onField(RegisterField field, String message) =>
        RegisterState(personalData: personal, errors: {field: message});

    return switch (error.code) {
      ApiErrorCode.usernameTaken => onField(
        RegisterField.username,
        'Ese nombre de usuario ya existe.',
      ),
      ApiErrorCode.emailTaken => onField(
        RegisterField.email,
        'Ese correo ya tiene una cuenta.',
      ),
      ApiErrorCode.passwordLength => onField(
        RegisterField.password,
        'Usa de 8 a 64 caracteres.',
      ),
      ApiErrorCode.passwordTooCommon => onField(
        RegisterField.password,
        'Es una contraseña muy común; elige otra.',
      ),
      ApiErrorCode.privacyPolicyNotAccepted => onField(
        RegisterField.privacyPolicy,
        'Acepta la política de privacidad para continuar.',
      ),
      // La app revisa lo mismo antes de enviar: llega solo si las reglas
      // cambiaron en la API.
      ApiErrorCode.validationError when error.fields.contains('email') =>
        onField(RegisterField.email, 'Escribe un correo válido.'),
      ApiErrorCode.validationError when error.fields.contains('username') =>
        onField(RegisterField.username, 'Revisa el nombre de usuario.'),
      ApiErrorCode.validationError => RegisterState(
        personalData: personal,
        errorMessage: 'Revisa tus datos e inténtalo de nuevo.',
      ),
      _ => RegisterState(
        personalData: personal,
        errorMessage: AuthMessages.general(error),
      ),
    };
  }
}

final registerViewModelProvider =
    NotifierProvider.autoDispose<RegisterViewModel, RegisterState>(
      RegisterViewModel.new,
    );
