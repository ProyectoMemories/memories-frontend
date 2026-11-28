import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/users_repository.dart';
import '../auth/session_notifier.dart';

/// Perfil de quien inició sesión, compartido por Inicio y Perfil
/// (design.md §3). Vale `null` sin sesión.
class MyProfileViewModel extends AsyncNotifier<Profile?> {
  @override
  Future<Profile?> build() async {
    // Se vuelve a construir cada vez que cambia la sesión: al entrar con otra
    // cuenta se pide de nuevo y nunca quedan los datos de la anterior
    // (RNF-02). Si la respuesta vieja llega tarde, Riverpod la descarta.
    final session = ref.watch(sessionProvider);
    if (session != SessionStatus.signedIn) return null;
    return ref.read(usersRepositoryProvider).myProfile();
  }

  /// Vuelve a pedir el perfil después de un error (botón de Perfil).
  void retry() => ref.invalidateSelf();
}

final myProfileProvider = AsyncNotifierProvider<MyProfileViewModel, Profile?>(
  MyProfileViewModel.new,
  // Sin reintentos solos: el reintento lo decide la persona.
  retry: (_, _) => null,
);
