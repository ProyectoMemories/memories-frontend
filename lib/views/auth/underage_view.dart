import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_router.dart';
import '../widgets/app_buttons.dart';
import '../widgets/auth_layouts.dart';

/// Menor de 14 (RN-08): pantalla "Todavía no puedes crear una cuenta".
class UnderageView extends StatelessWidget {
  const UnderageView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthMessageScaffold(
      topBar: AuthTopBar(
        title: 'Crear cuenta',
        onBack: () => context.go(AppRoutes.register),
      ),
      icon: Icons.lock_outline,
      title: 'Todavía no puedes crear una cuenta',
      body: const Text(
        'Memories es para personas de 14 años o más. No guardamos los datos '
        'que ingresaste.',
      ),
      actions: [
        SecondaryButton(
          label: 'Volver al inicio',
          onPressed: () => context.go(AppRoutes.login),
        ),
      ],
    );
  }
}
