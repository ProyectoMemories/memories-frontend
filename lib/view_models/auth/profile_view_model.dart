import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/api_error.dart';
import 'session_notifier.dart';

/// Estado de Perfil (design.md §4): por ahora solo cerrar sesión.
class ProfileState {
  const ProfileState({this.isLoggingOut = false});

  final bool isLoggingOut;
}

class ProfileViewModel extends Notifier<ProfileState> {
  @override
  ProfileState build() => const ProfileState();

  /// Cierra la sesión (HU-06). `SessionNotifier` deja la app sin sesión y el
  /// router lleva a Iniciar sesión, aunque la API falle.
  Future<void> logOut() async {
    if (state.isLoggingOut) return;
    state = const ProfileState(isLoggingOut: true);
    try {
      await ref.read(sessionProvider.notifier).logOut();
    } on ApiError {
      // Sin conexión los tokens del dispositivo ya se borraron y la persona
      // sale igual; la sesión del servidor vence sola (30 días como máximo).
      // No hay nada que mostrar: esta pantalla ya no está.
    } finally {
      if (ref.mounted) state = const ProfileState();
    }
  }
}

final profileViewModelProvider =
    NotifierProvider.autoDispose<ProfileViewModel, ProfileState>(
      ProfileViewModel.new,
    );
