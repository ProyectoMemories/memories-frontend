import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/config/app_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/entities/app_user.dart';
import 'features/auth/presentation/providers/auth_providers.dart';

class MemoriesApp extends ConsumerWidget {
  const MemoriesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);
    final AsyncValue<AppUser?> sesion = ref.watch(authControllerProvider);

    // Mientras se comprueba si hay una sesion guardada se muestra la pantalla de
    // carga: asi nadie ve la pantalla de inicio de sesion durante un instante
    // para que desaparezca enseguida.
    if (sesion.isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const _PantallaDeCarga(),
      );
    }

    return MaterialApp.router(
      title: 'Memories',
      // La cinta de "debug" solo molesta al ensenar la app.
      debugShowCheckedModeBanner: AppConfig.isDevelopment,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}

class _PantallaDeCarga extends StatelessWidget {
  const _PantallaDeCarga();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.auto_stories_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
