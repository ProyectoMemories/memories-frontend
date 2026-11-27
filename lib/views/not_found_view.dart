import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';
import 'widgets/app_buttons.dart';

/// Una ruta que no existe. Sin sesión, "Ir a Inicio" termina en Iniciar
/// sesión por la redirección del router.
class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'No encontramos esta página.',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Ir a Inicio',
                    onPressed: () => context.go(AppRoutes.home),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
