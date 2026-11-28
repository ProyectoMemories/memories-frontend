import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/users_repository.dart';
import '../auth/session_notifier.dart';

/// Perfil de quien inició sesión, compartido por Inicio y Perfil
/// (design.md §3). Sin sesión se recalcula como `null` en cuanto alguien lo
/// lee; mientras tanto puede guardar el perfil anterior, pero solo como
/// valor previo de un `AsyncLoading`: las vistas muestran solo `AsyncData`.
class MyProfileViewModel extends AsyncNotifier<Profile?> {
  @override
  Future<Profile?> build() async {
    // Se vuelve a construir cada vez que cambia la sesión: al entrar con otra
    // cuenta se pide de nuevo y nunca quedan los datos de la anterior
    // (RNF-02). Si la respuesta vieja llega tarde, Riverpod la descarta.
    // Depende de que un cambio de cuenta pase siempre por `signedOut` (hoy el
    // router no deja abrir el login con sesión): si algún día se cambia de
    // cuenta sin salir, hay que vigilar también quién es la cuenta.
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
