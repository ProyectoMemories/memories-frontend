import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../view_models/auth/session_notifier.dart';
import 'auth/check_email_view.dart';
import 'auth/login_view.dart';
import 'auth/profile_view.dart';
import 'auth/register_access_view.dart';
import 'auth/register_view.dart';
import 'auth/splash_view.dart';
import 'auth/underage_view.dart';
import 'auth/verify_email_view.dart';
import 'home_view.dart';
import 'not_found_view.dart';

/// Rutas de la app (design.md §4). En inglés; las que abre el correo las fija
/// el backend (D65, D73).
abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const registerAccess = '/register/access';
  static const registerUnderage = '/register/underage';
  static const checkEmail = '/check-email';
  static const verifyEmail = '/verify-email';
  static const home = '/home';
  static const profile = '/profile';
}

/// Rutas que se ven sin sesión. Incluye las que llegan en F7 para que la
/// regla no cambie al agregarlas. Con sesión llevan a Inicio, salvo las de
/// [_linkPaths].
const _authPaths = {
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.registerAccess,
  AppRoutes.registerUnderage,
  AppRoutes.checkEmail,
  AppRoutes.verifyEmail,
  '/forgot-password',
  '/reset-password',
};

/// Las abre el enlace de un correo: se ven con o sin sesión, para que el
/// enlace nunca se pierda (design §7). Verificar no toca la sesión abierta,
/// aunque el enlace sea de otra cuenta.
const _linkPaths = {AppRoutes.verifyEmail};

bool _isAuthPath(String path) => _authPaths.contains(path);

bool _isLinkPath(String path) => _linkPaths.contains(path);

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
      SessionStatus.signedIn
          when from != null &&
              (!_isAuthPath(from.path) || _isLinkPath(from.path)) =>
        from.toString(),
      SessionStatus.signedOut when from != null && _isAuthPath(from.path) =>
        from.toString(),
      SessionStatus.signedIn => AppRoutes.home,
      _ => AppRoutes.login,
    };
  }

  final isAuth = _isAuthPath(path);
  if (status == SessionStatus.signedIn && isAuth && !_isLinkPath(path)) {
    return AppRoutes.home;
  }
  if (status == SessionStatus.signedOut && !isAuth) return AppRoutes.login;
  return null;
}

/// Solo rutas de esta app: un `from` con otro sitio no se sigue, y uno que
/// vuelve a la carga tampoco (encadenarlos agotaría las redirecciones).
Uri? _sameSiteLocation(String? from) {
  final uri = from == null ? null : Uri.tryParse(from);
  if (uri == null || uri.hasScheme || uri.hasAuthority) return null;
  if (!uri.path.startsWith('/') || uri.path == AppRoutes.splash) return null;
  return uri;
}

final routerProvider = Provider<GoRouter>((ref) {
  // go_router vuelve a evaluar la redirección cuando esto cambia.
  final session = ValueNotifier(ref.read(sessionProvider));
  ref.listen(sessionProvider, (_, next) => session.value = next);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: session,
    redirect: (context, state) => redirectFor(session.value, state.uri),
    errorBuilder: (context, state) => const NotFoundView(),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginView(),
      ),
      // Antes que /register: es otra pantalla, no una subruta. Al llegar aquí
      // se descarta el registro entero ("No guardamos los datos").
      GoRoute(
        path: AppRoutes.registerUnderage,
        builder: (context, state) => const UnderageView(),
      ),
      // El paso 2 es subruta del 1: atrás vuelve al paso 1 con lo escrito.
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterView(),
        routes: [
          GoRoute(
            path: 'access',
            builder: (context, state) => const RegisterAccessView(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.checkEmail,
        builder: (context, state) => CheckEmailView(
          email: state.extra is String ? state.extra as String : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        builder: (context, state) =>
            VerifyEmailView(token: state.uri.queryParameters['token']),
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
