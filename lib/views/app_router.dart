import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../view_models/auth/session_notifier.dart';
import 'auth/login_view.dart';
import 'auth/splash_view.dart';
import 'home_view.dart';
import 'profile_view.dart';

/// Rutas de la app (design.md §4). En inglés; las que abre el correo las fija
/// el backend (D65, D73).
abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const profile = '/profile';
}

/// Rutas que se ven sin sesión. Incluye las que llegan en F6 y F7 para que
/// la regla no cambie al agregarlas.
const _authPaths = {
  AppRoutes.login,
  '/register',
  '/register/access',
  '/register/underage',
  '/check-email',
  '/verify-email',
  '/forgot-password',
  '/reset-password',
};

bool _isAuthPath(String path) => _authPaths.contains(path);

/// A dónde llevar a la persona según su sesión, o null para dejarla donde
/// está. Sin sesión solo ve las rutas de auth; con sesión, esas llevan a
/// Inicio. Mientras se comprueba, espera en la carga y se recuerda el destino.
String? redirectFor(SessionStatus status, Uri location) {
  final path = location.path;

  if (status == SessionStatus.checking) {
    if (path == AppRoutes.splash) return null;
    return Uri(
      path: AppRoutes.splash,
      queryParameters: {'from': location.toString()},
    ).toString();
  }

  if (path == AppRoutes.splash) {
    final from = _sameSiteLocation(location.queryParameters['from']);
    return switch (status) {
      SessionStatus.signedIn when from != null && !_isAuthPath(from.path) =>
        from.toString(),
      SessionStatus.signedOut when from != null && _isAuthPath(from.path) =>
        from.toString(),
      SessionStatus.signedIn => AppRoutes.home,
      _ => AppRoutes.login,
    };
  }

  final isAuth = _isAuthPath(path);
  if (status == SessionStatus.signedIn && isAuth) return AppRoutes.home;
  if (status == SessionStatus.signedOut && !isAuth) return AppRoutes.login;
  return null;
}

/// Solo rutas de esta app: un `from` con otro sitio no se sigue.
Uri? _sameSiteLocation(String? from) {
  final uri = from == null ? null : Uri.tryParse(from);
  if (uri == null || uri.hasScheme || uri.hasAuthority) return null;
  return uri.path.startsWith('/') ? uri : null;
}

final routerProvider = Provider<GoRouter>((ref) {
  // go_router vuelve a evaluar la redirección cuando esto cambia.
  final session = ValueNotifier(ref.read(sessionProvider));
  ref.listen(sessionProvider, (_, next) => session.value = next);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: session,
    redirect: (context, state) => redirectFor(session.value, state.uri),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileView(),
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    session.dispose();
  });
  return router;
});
