import '../../domain/entities/auth_session.dart';
import 'user_dto.dart';

class SessionDto {
  const SessionDto._();

  static AuthSession desdeJson(Map<String, dynamic> json) {
    return AuthSession(
      user: UserDto.desdeJson(json['user'] as Map<String, dynamic>),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }
}
