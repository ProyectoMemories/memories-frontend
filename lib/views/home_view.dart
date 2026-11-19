import 'package:flutter/material.dart';

/// Pantalla de inicio provisional: solo confirma que la app arranca. La
/// reemplaza la pantalla del mockup cuando llegue el login (F5).
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Memories')));
  }
}
