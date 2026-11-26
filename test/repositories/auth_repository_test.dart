import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/repositories/api_error.dart';
import 'package:memories/repositories/auth_repository.dart';
import 'package:memories/repositories/session/refresh_gate.dart';
import 'package:memories/repositories/session/token_store.dart';
import 'package:memories_api/memories_api.dart';

import 'fake_http_adapter.dart';

void main() {
  late FakeHttpAdapter adapter;
  late InMemoryTokenStore store;
  late RefreshGate gate;

  AuthRepository buildRepository(ClientPlatform platform) {
    final dio = Dio(BaseOptions(baseUrl: 'http://api.test'))
      ..httpClientAdapter = adapter;
    return AuthRepository(
      api: MemoriesApi(dio: dio).getAuthApi(),
      tokenStore: store,
      platform: platform,
      refreshGate: gate,
    );
  }

  setUp(() {
    adapter = FakeHttpAdapter((_) async => jsonReply(204));
    store = InMemoryTokenStore();
    gate = RefreshGate();
  });

  group('login', () {
    test('en Android envía la plataforma y guarda los dos tokens', () async {
      adapter.handler = (_) async =>
          jsonReply(200, tokenBody('acceso-1', 'sesion.secreto-1'));

      await buildRepository(ClientPlatform.android)
          .login(identifier: 'ana@ejemplo.pe', password: 'clave-segura');

      final request = adapter.requests.single;
      expect(request.path, '/api/v1/auth/login');
      expect(request.data, {
        'identifier': 'ana@ejemplo.pe',
        'password': 'clave-segura',
        'platform': 'android',
      });
      expect(store.tokens?.accessToken, 'acceso-1');
      expect(store.tokens?.refreshToken, 'sesion.secreto-1');
    });

    test('en web envía platform web y guarda solo el de acceso', () async {
      adapter.handler = (_) async => jsonReply(200, tokenBody('acceso-1'));

      await buildRepository(ClientPlatform.web)
          .login(identifier: 'ana', password: 'clave-segura');

      expect((adapter.requests.single.data as Map)['platform'], 'web');
      expect(store.tokens?.accessToken, 'acceso-1');
      expect(store.tokens?.refreshToken, isNull);
    });

    test('datos incorrectos: invalidCredentials y no guarda nada', () async {
      adapter.handler = (_) async => apiError(401, 'invalid_credentials');

      await expectLater(
        buildRepository(ClientPlatform.android)
            .login(identifier: 'ana', password: 'otra-clave'),
        throwsApiError(ApiErrorCode.invalidCredentials),
      );
      expect(store.tokens, isNull);
    });

    test('cuenta sin verificar y suspendida tienen su propio código', () async {
      final repository = buildRepository(ClientPlatform.android);

      adapter.handler = (_) async => apiError(403, 'email_not_verified');
      await expectLater(
        repository.login(identifier: 'ana', password: 'clave-segura'),
        throwsApiError(ApiErrorCode.emailNotVerified),
      );

      adapter.handler = (_) async => apiError(403, 'account_suspended');
      await expectLater(
        repository.login(identifier: 'ana', password: 'clave-segura'),
        throwsApiError(ApiErrorCode.accountSuspended),
      );
    });

    test('demasiados intentos: trae los segundos de Retry-After', () async {
      adapter.handler = (_) async =>
          apiError(429, 'too_many_requests', {'retry-after': '42'});

      await expectLater(
        buildRepository(ClientPlatform.android)
            .login(identifier: 'ana', password: 'clave-segura'),
        throwsA(
          isA<ApiError>()
              .having((e) => e.code, 'code', ApiErrorCode.tooManyRequests)
              .having(
                (e) => e.retryAfter,
                'retryAfter',
                const Duration(seconds: 42),
              ),
        ),
      );
    });

    test('sin conexión o error 5xx: network', () async {
      final repository = buildRepository(ClientPlatform.android);

      adapter.handler = (request) async => throw DioException.connectionError(
        requestOptions: request,
        reason: 'sin red',
      );
      await expectLater(
        repository.login(identifier: 'ana', password: 'clave-segura'),
        throwsApiError(ApiErrorCode.network),
      );

      adapter.handler = (_) async => jsonReply(503, {'detail': 'caído'});
      await expectLater(
        repository.login(identifier: 'ana', password: 'clave-segura'),
        throwsApiError(ApiErrorCode.network),
      );
    });

    test('un code que la app no conoce: unknown', () async {
      adapter.handler = (_) async => apiError(400, 'algo_nuevo');

      await expectLater(
        buildRepository(ClientPlatform.android)
            .login(identifier: 'ana', password: 'clave-segura'),
        throwsApiError(ApiErrorCode.unknown),
      );
    });
  });

  group('refresh', () {
    test('en Android envía el token guardado y guarda el rotado', () async {
      store.tokens = const SessionTokens(
        accessToken: 'acceso-1',
        refreshToken: 'sesion.secreto-1',
      );
      adapter.handler = (_) async =>
          jsonReply(200, tokenBody('acceso-2', 'sesion.secreto-2'));

      await buildRepository(ClientPlatform.android).refresh();

      final request = adapter.requests.single;
      expect(request.path, '/api/v1/auth/refresh');
      expect(request.data, {'refresh_token': 'sesion.secreto-1'});
      expect(store.tokens?.accessToken, 'acceso-2');
      expect(store.tokens?.refreshToken, 'sesion.secreto-2');
    });

    test('en web va sin cuerpo: el navegador manda la cookie', () async {
      adapter.handler = (_) async => jsonReply(200, tokenBody('acceso-2'));

      await buildRepository(ClientPlatform.web).refresh();

      expect(adapter.requests.single.data, isNull);
      expect(store.tokens?.accessToken, 'acceso-2');
    });

    test('en Android sin token guardado no llama a la API', () async {
      await expectLater(
        buildRepository(ClientPlatform.android).refresh(),
        throwsApiError(ApiErrorCode.invalidRefreshToken),
      );
      expect(adapter.requests, isEmpty);
    });

    test('dos renovaciones a la vez = una sola petición a la API', () async {
      store.tokens = const SessionTokens(
        accessToken: 'acceso-1',
        refreshToken: 'sesion.secreto-1',
      );
      adapter.handler = (_) async =>
          jsonReply(200, tokenBody('acceso-2', 'sesion.secreto-2'));
      final repository = buildRepository(ClientPlatform.android);

      await Future.wait([repository.refresh(), repository.refresh()]);

      expect(adapter.requests, hasLength(1));
    });

    test('sesión revocada o vencida: invalidRefreshToken', () async {
      store.tokens = const SessionTokens(
        accessToken: 'acceso-1',
        refreshToken: 'sesion.secreto-1',
      );
      adapter.handler = (_) async => apiError(401, 'invalid_refresh_token');

      await expectLater(
        buildRepository(ClientPlatform.android).refresh(),
        throwsApiError(ApiErrorCode.invalidRefreshToken),
      );
    });
  });

  group('logout', () {
    test(
      'en Android revoca con el token guardado y borra los locales',
      () async {
        store.tokens = const SessionTokens(
          accessToken: 'acceso-1',
          refreshToken: 'sesion.secreto-1',
        );

        await buildRepository(ClientPlatform.android).logout();

        final request = adapter.requests.single;
        expect(request.path, '/api/v1/auth/logout');
        expect(request.data, {'refresh_token': 'sesion.secreto-1'});
        expect(store.tokens, isNull);
      },
    );

    test('con una renovación en curso, espera y revoca con el token '
        'rotado', () async {
      store.tokens = const SessionTokens(
        accessToken: 'acceso-1',
        refreshToken: 'sesion.secreto-1',
      );
      final refreshAnswer = Completer<void>();
      adapter.handler = (request) async {
        if (request.path.endsWith('/refresh')) {
          await refreshAnswer.future;
          return jsonReply(200, tokenBody('acceso-2', 'sesion.secreto-2'));
        }
        return jsonReply(204);
      };
      final repository = buildRepository(ClientPlatform.android);

      final renewal = repository.refresh();
      await pumpEventQueue();
      final loggingOut = repository.logout();
      await pumpEventQueue();
      refreshAnswer.complete();
      await Future.wait([renewal, loggingOut]);

      // Con el token viejo la API vería reuso; y la renovación tardía no
      // vuelve a guardar tokens después de cerrar sesión.
      expect(adapter.requests.last.path, '/api/v1/auth/logout');
      expect(adapter.requests.last.data, {'refresh_token': 'sesion.secreto-2'});
      expect(store.tokens, isNull);
    });

    test('en web va sin cuerpo', () async {
      store.tokens = const SessionTokens(accessToken: 'acceso-1');

      await buildRepository(ClientPlatform.web).logout();

      expect(adapter.requests.single.data, isNull);
      expect(store.tokens, isNull);
    });

    test('si la API falla, igual borra los tokens y avisa el error', () async {
      store.tokens = const SessionTokens(
        accessToken: 'acceso-1',
        refreshToken: 'sesion.secreto-1',
      );
      adapter.handler = (request) async => throw DioException.connectionError(
        requestOptions: request,
        reason: 'sin red',
      );

      await expectLater(
        buildRepository(ClientPlatform.android).logout(),
        throwsApiError(ApiErrorCode.network),
      );
      expect(store.tokens, isNull);
    });
  });
}

Matcher throwsApiError(ApiErrorCode code) =>
    throwsA(isA<ApiError>().having((e) => e.code, 'code', code));
