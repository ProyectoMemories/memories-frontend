import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../repositories/api_error.dart';
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

    return switch (ref.watch(provider)) {
      AsyncData(value: VerifyEmailResult.verified) => AuthMessageScaffold(
        icon: Icons.mark_email_read_outlined,
        title: 'Correo verificado',
        body: const Text('Tu cuenta ya está activa. Ya puedes iniciar sesión.'),
        actions: [
          PrimaryButton(
            label: 'Iniciar sesión',
            onPressed: () => context.go(AppRoutes.login),
          ),
        ],
      ),
      AsyncData(value: VerifyEmailResult.linkInvalid) => AuthMessageScaffold(
        icon: Icons.link_off,
        title: 'El enlace venció',
        body: const Text(AuthMessages.linkInvalid),
        actions: [
          PrimaryButton(
            label: 'Pedir otro enlace',
            onPressed: () => context.go(AppRoutes.checkEmail),
          ),
          SecondaryButton(
            label: 'Iniciar sesión',
            onPressed: () => context.go(AppRoutes.login),
          ),
        ],
      ),
      AsyncError(:final error) => AuthMessageScaffold(
        icon: Icons.wifi_off,
        title: 'No pudimos verificar',
        body: Text(
          error is ApiError
              ? AuthMessages.general(error)
              : AuthMessages.unexpected,
        ),
        actions: [
          PrimaryButton(
            label: 'Reintentar',
            onPressed: () => ref.read(provider.notifier).retry(),
          ),
        ],
      ),
      _ => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            semanticsLabel: 'Verificando tu correo',
          ),
        ),
      ),
    };
  }
}
