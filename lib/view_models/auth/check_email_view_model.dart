import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/api_error.dart';
import '../../repositories/auth_repository.dart';
import 'auth_messages.dart';
import 'auth_validators.dart';

/// Estado de "Revisa tu correo" (HU-03).
@immutable
class CheckEmailState {
  const CheckEmailState({
    this.isResending = false,
    this.emailError,
    this.errorMessage,
  });

  final bool isResending;

  /// Solo cuando la pantalla pide el correo (no llegó desde el registro).
  final String? emailError;
  final String? errorMessage;
}

class CheckEmailViewModel extends Notifier<CheckEmailState> {
  @override
  CheckEmailState build() => const CheckEmailState();

  /// Reenvía el enlace. Devuelve true si la vista debe mostrar "Correo
  /// reenviado". La API responde igual exista o no la cuenta (D74).
  Future<bool> resend(String email) async {
    if (state.isResending) return false;
    final cleanEmail = email.trim();
    final emailError = AuthValidators.email(cleanEmail);
    if (emailError != null) {
      state = CheckEmailState(emailError: emailError);
      return false;
    }
    state = const CheckEmailState(isResending: true);
    try {
      await ref.read(authRepositoryProvider).resendVerification(cleanEmail);
      if (ref.mounted) state = const CheckEmailState();
      return true;
    } on ApiError catch (error) {
      if (ref.mounted) {
        state = CheckEmailState(errorMessage: AuthMessages.general(error));
      }
      return false;
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'memories',
          context: ErrorDescription('al reenviar el correo'),
        ),
      );
      if (ref.mounted) {
        state = const CheckEmailState(errorMessage: AuthMessages.unexpected);
      }
      return false;
    }
  }
}

final checkEmailViewModelProvider =
    NotifierProvider.autoDispose<CheckEmailViewModel, CheckEmailState>(
      CheckEmailViewModel.new,
    );
