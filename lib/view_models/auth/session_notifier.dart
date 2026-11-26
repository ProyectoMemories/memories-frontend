import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/api_error.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/session/session_expired_signal.dart';
import '../../repositories/session/token_store.dart';

/// Estado de la sesión de la app. Decide qué rutas se ven (design.md §4).
enum SessionStatus { checking, signedIn, signedOut }

class SessionNotifier extends Notifier<SessionStatus> {
  @override
  SessionStatus build() {
    ref.listen(sessionExpiredSignalProvider, (_, _) => sessionExpired());
    _restore();
    return SessionStatus.checking;
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<void> logIn({
    required String identifier,
    required String password,
  }) async {
    await _repository.login(identifier: identifier, password: password);
    _set(SessionStatus.signedIn);
  }

  /// Revoca la sesión y sale, aunque la API falle: el repositorio ya borró
  /// los tokens locales. El error sigue para que la pantalla decida.
  Future<void> logOut() async {
    try {
      await _repository.logout();
    } finally {
      _set(SessionStatus.signedOut);
    }
  }

  /// La renovación falló porque la sesión ya no vale (la llama el
  /// interceptor). Los tokens ya están borrados.
  void sessionExpired() => _set(SessionStatus.signedOut);

  /// Al abrir la app: en Android los tokens siguen guardados; en web el de
  /// acceso se perdió al recargar y se pide otro con la cookie (HU-06).
  Future<void> _restore() async {
    final tokens = await ref.read(tokenStoreProvider).read();
    if (tokens != null) return _set(SessionStatus.signedIn);
    try {
      await _repository.refresh();
      _set(SessionStatus.signedIn);
    } on ApiError {
      // Sin cookie válida, o sin conexión en web: hay que iniciar sesión.
      _set(SessionStatus.signedOut);
    }
  }

  void _set(SessionStatus status) {
    if (ref.mounted) state = status;
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionStatus>(
  SessionNotifier.new,
);
