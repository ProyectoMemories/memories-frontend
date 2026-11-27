import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../view_models/auth/auth_messages.dart';
import '../../view_models/auth/verify_email_view_model.dart';
import '../app_router.dart';
import '../widgets/app_buttons.dart';
import '../widgets/auth_layouts.dart';

/// `/verify-email?token=` (HU-03): verifica la cuenta al abrir el enlace del
/// correo. Con el estilo de "Verifica tu correo".
class VerifyEmailView extends ConsumerWidget {
  const VerifyEmailView({super.key, required this.token});

  final String? token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = verifyEmailViewModelProvider(token);
    void goToLogin() => context.go(AppRoutes.login);

    return switch (ref.watch(provider)) {
      AsyncData(value: VerifyEmailResult.verified) => AuthMessageScaffold(
        onBack: goToLogin,
        icon: Icons.mark_email_read_outlined,
        title: 'Correo verificado',
        body: const Text('Tu cuenta ya está activa. Ya puedes iniciar sesión.'),
        actions: [PrimaryButton(label: 'Iniciar sesión', onPressed: goToLogin)],
      ),
      AsyncData(value: VerifyEmailResult.linkInvalid) => AuthMessageScaffold(
        onBack: goToLogin,
        icon: Icons.link_off,
        title: 'El enlace venció',
        body: const Text(AuthMessages.linkInvalid),
        actions: [
          PrimaryButton(
            label: 'Pedir otro enlace',
            onPressed: () => context.go(AppRoutes.checkEmail),
          ),
          SecondaryButton(label: 'Iniciar sesión', onPressed: goToLogin),
        ],
      ),
      AsyncError(:final error) => AuthMessageScaffold(
        onBack: goToLogin,
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
          if (!didPop) goToLogin();
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
