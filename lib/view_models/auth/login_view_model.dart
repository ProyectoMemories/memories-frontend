import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/api_error.dart';
import 'session_notifier.dart';

/// Estado de la pantalla Iniciar sesión (design.md §4).
class LoginState {
  const LoginState({
    this.isSubmitting = false,
    this.errorMessage,
    this.identifierError,
    this.passwordError,
    this._errorAnnouncement,
  });

  final bool isSubmitting;

  /// Mensaje del envío para la persona (design.md §6), o null si no hay error.
  final String? errorMessage;

  /// Lo que anuncia el lector de pantalla. En la cuenta regresiva se queda
  /// con el primer mensaje: si cambiara cada segundo, lo anunciaría cada
  /// segundo.
  String? get errorAnnouncement => _errorAnnouncement ?? errorMessage;
  final String? _errorAnnouncement;

  /// Qué falta en cada campo, revisado antes de llamar a la API.
  final String? identifierError;
  final String? passwordError;
}

class LoginViewModel extends Notifier<LoginState> {
  Timer? _countdown;

  @override
  LoginState build() {
    ref.onDispose(_stopCountdown);
    return const LoginState();
  }

  /// Inicia sesión. Si sale bien, `SessionNotifier` pasa a "con sesión" y el
  /// router lleva a Inicio; esta pantalla no navega.
  Future<void> submit({
    required String identifier,
    required String password,
  }) async {
    // El botón ya no acepta toques mientras espera; esto cubre el Enter.
    if (state.isSubmitting) return;
    _stopCountdown();
    final identifierError = identifier.trim().isEmpty
        ? 'Escribe tu correo o nombre de usuario.'
        : null;
    final passwordError = password.isEmpty ? 'Escribe tu contraseña.' : null;
    if (identifierError != null || passwordError != null) {
      state = LoginState(
        identifierError: identifierError,
        passwordError: passwordError,
      );
      return;
    }
    state = const LoginState(isSubmitting: true);
    try {
      await ref
          .read(sessionProvider.notifier)
          // La contraseña va tal cual: un espacio puede ser parte de ella.
          .logIn(identifier: identifier.trim(), password: password);
      if (ref.mounted) state = const LoginState();
    } on ApiError catch (error) {
      if (!ref.mounted) return;
      state = LoginState(errorMessage: _messageFor(error));
      final seconds = error.retryAfter?.inSeconds;
      if (error.code == ApiErrorCode.tooManyRequests &&
          seconds != null &&
          seconds > 0) {
        _startCountdown(seconds);
      }
    } catch (error, stackTrace) {
      // Por ejemplo, el Keystore al guardar los tokens: sin esto el botón se
      // quedaría cargando para siempre.
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'memories',
          context: ErrorDescription('al iniciar sesión'),
        ),
      );
      if (ref.mounted) {
        state = const LoginState(
          errorMessage: 'Algo salió mal. Inténtalo de nuevo.',
        );
      }
    }
  }

  /// "Prueba en N segundos" baja de uno en uno y desaparece en cero, cuando
  /// ya se puede volver a intentar.
  void _startCountdown(int seconds) {
    final announcement = state.errorMessage;
    var remaining = seconds;
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;
      if (remaining <= 0) {
        _stopCountdown();
        state = const LoginState();
        return;
      }
      state = LoginState(
        errorMessage: _tooManyRequests(Duration(seconds: remaining)),
        errorAnnouncement: announcement,
      );
    });
  }

  void _stopCountdown() {
    _countdown?.cancel();
    _countdown = null;
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
