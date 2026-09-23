import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_session.dart';
import '../models/session_dto.dart';
import '../models/user_dto.dart';

/// Unico sitio que habla con los endpoints de autenticacion.
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AppUser> registrar({
    required String email,
    required String displayName,
    required String password,
  }) async {
    try {
      final Response<dynamic> respuesta = await _dio.post<dynamic>(
        ApiEndpoints.register,
        data: <String, dynamic>{
          'email': email,
          'display_name': displayName,
          'password': password,
        },
      );
      return UserDto.desdeJson(respuesta.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<AuthSession> iniciarSesion({
    required String email,
    required String password,
  }) async {
    try {
      final Response<dynamic> respuesta = await _dio.post<dynamic>(
        ApiEndpoints.login,
        data: <String, dynamic>{'email': email, 'password': password},
      );
      return SessionDto.desdeJson(respuesta.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> cerrarSesion(String? refreshToken) async {
    try {
      await _dio.post<dynamic>(
        ApiEndpoints.logout,
        data: <String, dynamic>{'refresh_token': refreshToken},
      );
    } on DioException {
      // Cerrar sesion nunca falla de cara a la persona: los tokens locales se
      // borran igual, que es lo que de verdad importa en este dispositivo.
    }
  }

  Future<AppUser> perfil() async {
    try {
      final Response<dynamic> respuesta = await _dio.get<dynamic>(ApiEndpoints.me);
      return UserDto.desdeJson(respuesta.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<AppUser> actualizarNombre(String displayName) async {
    try {
      final Response<dynamic> respuesta = await _dio.patch<dynamic>(
        ApiEndpoints.me,
        data: <String, dynamic>{'display_name': displayName},
      );
      return UserDto.desdeJson(respuesta.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
