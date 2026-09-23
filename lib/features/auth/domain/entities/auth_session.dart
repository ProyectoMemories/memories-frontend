import 'app_user.dart';

/// Sesion abierta: la persona y sus dos tokens.
class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  final AppUser user;
  final String accessToken;
  final String refreshToken;
}
