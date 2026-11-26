import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Aviso de que la sesión terminó sin que la persona la cerrara: la API
/// rechazó la renovación. Lo emite el interceptor y lo escucha
/// `SessionNotifier`, así los repositorios no dependen de los ViewModels.
class SessionExpiredSignal extends Notifier<int> {
  @override
  int build() => 0;

  void emit() => state++;
}

final sessionExpiredSignalProvider =
    NotifierProvider<SessionExpiredSignal, int>(SessionExpiredSignal.new);
