import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memories_api/memories_api.dart';

import 'api_client.dart';
import 'api_error.dart';

/// Único punto de la app que usa los endpoints de users (design.md §2).
///
/// El token lo pone `SessionInterceptor`: si la sesión ya no vale, él avisa y
/// la app vuelve a Iniciar sesión.
class UsersRepository {
  UsersRepository({required this._api});

  final UsersApi _api;

  /// Datos de la cuenta que inició sesión (`GET /users/me`).
  Future<Profile> myProfile() async {
    final Response<ProfileResponse> response;
    try {
      response = await _api.getMyProfileApiV1UsersMeGet();
    } on DioException catch (error) {
      throw ApiError.fromDio(error);
    }
    // Un 200 sin cuerpo no debería llegar; si llega, es un error de la API.
    final body = response.data;
    if (body == null) throw const ApiError(ApiErrorCode.unknown);
    return Profile(
      firstName: body.firstName,
      paternalSurname: body.paternalSurname,
      maternalSurname: body.maternalSurname,
      username: body.username,
      email: body.email,
    );
  }
}

/// Perfil de quien inició sesión, sin tipos del cliente generado (CLAUDE.md
/// §7).
class Profile {
  const Profile({
    required this.firstName,
    required this.paternalSurname,
    required this.maternalSurname,
    required this.username,
    required this.email,
  });

  final String firstName;
  final String paternalSurname;
  final String? maternalSurname;
  final String username;
  final String email;

  /// Nombre y apellido paterno, como en el mockup ("Victor Vergara").
  String get displayName => '$firstName $paternalSurname';

  /// Iniciales del avatar ("VV").
  String get initials =>
      '${_firstLetter(firstName)}${_firstLetter(paternalSurname)}';

  // Por runas y no por unidades UTF-16, para no partir un carácter en dos.
  static String _firstLetter(String text) =>
      text.isEmpty ? '' : String.fromCharCode(text.runes.first).toUpperCase();
}

final usersRepositoryProvider = Provider<UsersRepository>(
  (ref) => UsersRepository(api: ref.watch(memoriesApiProvider).getUsersApi()),
);
