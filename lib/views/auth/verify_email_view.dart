import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../view_models/auth/auth_messages.dart';
import '../../view_models/auth/session_notifier.dart';
import '../../view_models/auth/verify_email_view_model.dart';
import '../app_router.dart';
import '../widgets/app_buttons.dart';
import '../widgets/auth_layouts.dart';

/// `/verify-email?token=` (HU-03): verifica la cuenta al abrir el enlace del
/// correo. Con el estilo de "Verifica tu correo".
///
/// Se abre también con la sesión iniciada (design §7): verifica sin cerrarla
/// y ofrece volver a Inicio en vez de iniciar sesión.
class VerifyEmailView extends ConsumerWidget {
  const VerifyEmailView({super.key, required this.token});

  final String? token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = verifyEmailViewModelProvider(token);
    final signedIn = ref.watch(sessionProvider) == SessionStatus.signedIn;
    void leave() => context.go(signedIn ? AppRoutes.home : AppRoutes.login);
    final leaveButton = PrimaryButton(
      label: signedIn ? 'Ir a Inicio' : 'Iniciar sesión',
      onPressed: leave,
    );

    return switch (ref.watch(provider)) {
      AsyncData(value: VerifyEmailResult.verified) => AuthMessageScaffold(
        onBack: leave,
        icon: Icons.mark_email_read_outlined,
        title: 'Correo verificado',
        body: Text(
          signedIn
              ? 'La cuenta de este enlace ya está activa.'
              : 'Tu cuenta ya está activa. Ya puedes iniciar sesión.',
        ),
        actions: [leaveButton],
      ),
      AsyncData(value: VerifyEmailResult.linkInvalid) => AuthMessageScaffold(
        onBack: leave,
        icon: Icons.link_off,
        title: 'El enlace venció',
        body: const Text(AuthMessages.linkInvalid),
        // Con sesión, "Revisa tu correo" no se ve (lleva a Inicio): el otro
        // enlace se pide desde el navegador donde no hay sesión.
        actions: signedIn
            ? [leaveButton]
            : [
                PrimaryButton(
                  label: 'Pedir otro enlace',
                  onPressed: () => context.go(AppRoutes.checkEmail),
                ),
                SecondaryButton(label: 'Iniciar sesión', onPressed: leave),
              ],
      ),
      AsyncError(:final error) => AuthMessageScaffold(
        onBack: leave,
        icon: Icons.error_outline,
        title: 'No pudimos verificar',
        body: Text(VerifyEmailViewModel.messageFor(error)),
        actions: [
          PrimaryButton(
            label: 'Reintentar',
            onPressed: () => ref.read(provider.notifier).retry(),
          ),
        ],
      ),
      _ => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) leave();
        },
        child: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              semanticsLabel: 'Verificando tu correo',
            ),
          ),
        ),
      ),
    };
  }
}
