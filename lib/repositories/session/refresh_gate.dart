import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'token_store.dart';

/// Hace que las renovaciones del token vayan de una en una (D56, CLAUDE.md §8).
///
/// Dos renovaciones con el mismo token de renovación se ven como reuso y la API
/// revoca la sesión. Por eso todo el que renueva o usa ese token (el
/// interceptor, la recuperación al abrir la app y el cierre de sesión) pasa
/// por la misma instancia.
class RefreshGate {
  Future<SessionTokens>? _inFlight;

  /// Corre [refresh], o devuelve la renovación que ya está en curso.
  Future<SessionTokens> run(Future<SessionTokens> Function() refresh) {
    return _inFlight ??= refresh().whenComplete(() => _inFlight = null);
  }

  /// Espera a que termine la renovación en curso, si hay una.
  Future<void> idle() async {
    final inFlight = _inFlight;
    if (inFlight == null) return;
    try {
      await inFlight;
    } on Object {
      // El resultado, éxito o error, lo maneja quien inició la renovación;
      // aquí solo importa que ya no siga en curso.
    }
  }
}

final refreshGateProvider = Provider<RefreshGate>((ref) => RefreshGate());
