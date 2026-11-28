import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/repositories/api_error.dart';
import 'package:memories/repositories/users_repository.dart';
import 'package:memories_api/memories_api.dart';

import 'auth_repository_test.dart' show throwsApiError;
import 'fake_http_adapter.dart';

Map<String, Object?> profileBody({String? maternalSurname = 'Ríos'}) => {
  'id': '0193a7e2-0000-7000-8000-000000000001',
  'username': 'ana.paz',
  'email': 'ana@ejemplo.pe',
  'first_name': 'Ana',
  'paternal_surname': 'Paz',
  'maternal_surname': maternalSurname,
};

void main() {
  late FakeHttpAdapter adapter;

  UsersRepository buildRepository() {
    final dio = Dio(BaseOptions(baseUrl: 'http://api.test'))
      ..httpClientAdapter = adapter;
    return UsersRepository(api: MemoriesApi(dio: dio).getUsersApi());
  }

  setUp(() => adapter = FakeHttpAdapter((_) async => jsonReply(204)));

  group('myProfile', () {
    test('pide GET /users/me y traduce la respuesta', () async {
      adapter.handler = (_) async => jsonReply(200, profileBody());

      final profile = await buildRepository().myProfile();

      final request = adapter.requests.single;
      expect(request.method, 'GET');
      expect(request.path, '/api/v1/users/me');
      expect(profile.firstName, 'Ana');
      expect(profile.paternalSurname, 'Paz');
      expect(profile.maternalSurname, 'Ríos');
      expect(profile.username, 'ana.paz');
      expect(profile.email, 'ana@ejemplo.pe');
    });

    test('sin apellido materno queda null', () async {
      adapter.handler = (_) async =>
          jsonReply(200, profileBody(maternalSurname: null));

      final profile = await buildRepository().myProfile();

      expect(profile.maternalSurname, isNull);
    });

    test('sin conexión o 5xx: ApiError de red', () async {
      adapter.handler = (_) async => jsonReply(503);

      await expectLater(
        buildRepository().myProfile(),
        throwsApiError(ApiErrorCode.network),
      );
    });

    test('sesión no válida: notAuthenticated', () async {
      adapter.handler = (_) async => apiError(401, 'not_authenticated');

      await expectLater(
        buildRepository().myProfile(),
        throwsApiError(ApiErrorCode.notAuthenticated),
      );
    });
  });

  group('Profile', () {
    const ana = Profile(
      firstName: 'Ana',
      paternalSurname: 'Paz',
      maternalSurname: 'Ríos',
      username: 'ana.paz',
      email: 'ana@ejemplo.pe',
    );

    test('displayName es nombre y apellido paterno', () {
      expect(ana.displayName, 'Ana Paz');
    });

    test('initials son la primera letra de cada uno, en mayúsculas', () {
      expect(ana.initials, 'AP');
      const angela = Profile(
        firstName: 'ángela',
        paternalSurname: 'órdenes',
        maternalSurname: null,
        username: 'angela',
        email: 'angela@ejemplo.pe',
      );
      expect(angela.initials, 'ÁÓ');
    });
  });
}
