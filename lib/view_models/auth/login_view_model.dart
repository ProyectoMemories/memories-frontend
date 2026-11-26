import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/api_error.dart';
import 'session_notifier.dart';

/// Estado de la pantalla Iniciar sesión (design.md §4).
class LoginState {
  const LoginState({this.isSubmitting = false, this.errorMessage});

  final bool isSubmitting;

  /// Mensaje para la persona (design.md §6), o null si no hay error.
  final String? errorMessage;
}

class LoginViewModel extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  /// Inicia sesión. Si sale bien, `SessionNotifier` pasa a "con sesión" y el
  /// router lleva a Inicio; esta pantalla no navega.
  Future<void> submit({
    required String identifier,
    required String password,
  }) async {
    // El botón ya no acepta toques mientras espera; esto cubre el Enter.
    if (state.isSubmitting) return;
    state = const LoginState(isSubmitting: true);
    try {
      await ref
          .read(sessionProvider.notifier)
          // La contraseña va tal cual: un espacio puede ser parte de ella.
          .logIn(identifier: identifier.trim(), password: password);
      if (ref.mounted) state = const LoginState();
    } on ApiError catch (error) {
      if (ref.mounted) state = LoginState(errorMessage: _messageFor(error));
    }
  }

  static String _messageFor(ApiError error) {
    return switch (error.code) {
      ApiErrorCode.invalidCredentials =>
        'El usuario o la contraseña no son correctos.',
      // F6 cambia esto por ir a "Revisa tu correo" (design §6).
      ApiErrorCode.emailNotVerified =>
        'Tu cuenta todavía no está verificada. Revisa tu correo para '
            'activarla.',
      ApiErrorCode.accountSuspended => 'Esta cuenta está suspendida.',
      ApiErrorCode.tooManyRequests => _tooManyRequests(error.retryAfter),
      ApiErrorCode.network =>
        'No pudimos conectar. Revisa tu conexión e inténtalo de nuevo.',
      _ => 'Algo salió mal. Inténtalo de nuevo.',
    };
  }

  static String _tooManyRequests(Duration? retryAfter) {
    final seconds = retryAfter?.inSeconds;
    if (seconds == null || seconds <= 0) {
      return 'Demasiados intentos. Prueba en un momento.';
    }
    final unit = seconds == 1 ? 'segundo' : 'segundos';
    return 'Demasiados intentos. Prueba en $seconds $unit.';
  }
}

final loginViewModelProvider =
    NotifierProvider.autoDispose<LoginViewModel, LoginState>(
      LoginViewModel.new,
    );
