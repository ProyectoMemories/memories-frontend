import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../view_models/users/my_profile_view_model.dart';
import 'app_router.dart';
import 'widgets/app_bottom_bar.dart';

/// Saludo de "Inicio: álbumes" según la hora del día.
String greetingFor(DateTime now) {
  final hour = now.hour;
  if (hour >= 5 && hour < 12) return 'Buenos días';
  if (hour >= 12 && hour < 19) return 'Buenas tardes';
  return 'Buenas noches';
}

/// Inicio provisional (HU-07): la estructura de "Inicio: álbumes" sin
/// álbumes, que llegan con su módulo (D78).
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Greeting(),
                  const SizedBox(height: 2),
                  Text('Tus álbumes', style: textTheme.headlineMedium),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomBar(
        current: AppTab.home,
        onSelect: (tab) => goToTab(context, tab),
      ),
    );
  }
}

/// "Buenas noches, Victor". Mientras carga o si falla, solo el saludo: no es
/// crítico y no muestra errores (users, requirements HU-01).
class _Greeting extends ConsumerWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Solo con datos ya cargados: nunca un nombre que se está reemplazando.
    final firstName = switch (ref.watch(myProfileProvider)) {
      AsyncData(:final value) => value?.firstName,
      _ => null,
    };
    final greeting = greetingFor(DateTime.now());
    return Text(
      firstName == null ? greeting : '$greeting, $firstName',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 14),
    );
  }
}

/// Navegación de la barra inferior, compartida por Inicio y Perfil.
void goToTab(BuildContext context, AppTab tab) {
  context.go(switch (tab) {
    AppTab.home => AppRoutes.home,
    AppTab.profile => AppRoutes.profile,
  });
}
