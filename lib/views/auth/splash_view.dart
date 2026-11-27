import 'package:flutter/material.dart';

/// Se ve mientras `SessionNotifier` comprueba si hay sesión al abrir la app.
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(semanticsLabel: 'Cargando'),
      ),
    );
  }
}
