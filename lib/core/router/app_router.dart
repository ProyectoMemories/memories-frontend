import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/memories/presentation/pages/calendar_page.dart';
import '../../features/memories/presentation/pages/memories_page.dart';
import '../../features/memories/presentation/pages/memory_detail_page.dart';
import '../../features/memories/presentation/pages/memory_form_page.dart';
import '../../features/memories/presentation/pages/revive_page.dart';
import 'home_shell.dart';

/// Avisa a go_router cuando cambia la sesion, para que reevalue el redirect.
class _RefrescoDeSesion extends ChangeNotifier {
  void avisar() => notifyListeners();
}

final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final _RefrescoDeSesion refresco = _RefrescoDeSesion();
  ref.listen<AsyncValue<AppUser?>>(
    authControllerProvider,
    (AsyncValue<AppUser?>? _, AsyncValue<AppUser?> __) => refresco.avisar(),
  );
  ref.onDispose(refresco.dispose);

  return GoRouter(
    initialLocation: '/memories',
    refreshListenable: refresco,
    debugLogDiagnostics: kDebugMode,
    redirect: (BuildContext context, GoRouterState state) {
      final AsyncValue<AppUser?> sesion = ref.read(authControllerProvider);

      // Mientras se comprueba la sesion guardada no se decide nada: la pantalla
      // de carga se encarga.
      if (sesion.isLoading) {
        return null;
      }

      final bool autenticado = sesion.valueOrNull != null;
      final bool enPantallaDeEntrada =
          state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!autenticado && !enPantallaDeEntrada) {
        return '/login';
      }
      if (autenticado && enPantallaDeEntrada) {
        return '/memories';
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (BuildContext context, GoRouterState state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/memories',
        builder: (BuildContext context, GoRouterState state) =>
            const HomeShell(indice: 0, child: MemoriesPage()),
        routes: <RouteBase>[
          GoRoute(
            path: 'new',
            builder: (BuildContext context, GoRouterState state) =>
                const MemoryFormPage(),
          ),
          GoRoute(
            path: ':id',
            builder: (BuildContext context, GoRouterState state) =>
                MemoryDetailPage(memoryId: state.pathParameters['id']!),
            routes: <RouteBase>[
              GoRoute(
                path: 'edit',
                builder: (BuildContext context, GoRouterState state) =>
                    MemoryFormPage(memoryId: state.pathParameters['id']),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/calendar',
        builder: (BuildContext context, GoRouterState state) =>
            const HomeShell(indice: 1, child: CalendarPage()),
      ),
      GoRoute(
        path: '/revive',
        builder: (BuildContext context, GoRouterState state) =>
            const HomeShell(indice: 2, child: RevivePage()),
      ),
      GoRoute(
        path: '/profile',
        builder: (BuildContext context, GoRouterState state) =>
            const HomeShell(indice: 3, child: ProfilePage()),
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
      body: Center(child: Text('Esta pagina no existe: ${state.uri}')),
    ),
  );
});
