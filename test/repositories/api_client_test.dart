import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/app_config.dart';
import 'package:memories/repositories/api_client.dart';
import 'package:memories/repositories/session/session_interceptor.dart';
import 'package:memories/repositories/session/token_store.dart';
import 'package:memories/view_models/auth/session_notifier.dart';
import 'package:memories_api/memories_api.dart';

import 'fake_http_adapter.dart';

void main() {
  group('memoriesApiProvider', () {
    test('crea el cliente con la API_BASE_URL de app_config', () {
      final container = ProviderContainer.test(
        overrides: [
          apiBaseUrlProvider.overrideWithValue('http://10.0.2.2:8001'),
        ],
      );

      final api = container.read(memoriesApiProvider);

      expect(api.dio.options.baseUrl, 'http://10.0.2.2:8001');
    });

    test('usa tiempos de espera propios, no los del generador', () {
      final api = ProviderContainer.test(
        overrides: [apiBaseUrlProvider.overrideWithValue('http://api.test')],
      ).read(memoriesApiProvider);

      expect(api.dio.options.connectTimeout, const Duration(seconds: 10));
      expect(api.dio.options.receiveTimeout, const Duration(seconds: 15));
    });

    test('solo lleva el interceptor de sesión, sin los del generador', () {
      final api = ProviderContainer.test(
        overrides: [apiBaseUrlProvider.overrideWithValue('http://api.test')],
      ).read(memoriesApiProvider);
      final interceptors = api.dio.interceptors;

      expect(interceptors.whereType<SessionInterceptor>(), hasLength(1));
      expect(interceptors.whereType<BearerAuthInterceptor>(), isEmpty);
      expect(interceptors.whereType<OAuthInterceptor>(), isEmpty);
      expect(interceptors.whereType<BasicAuthInterceptor>(), isEmpty);
      expect(interceptors.whereType<ApiKeyAuthInterceptor>(), isEmpty);
    });

    test('si la API revoca la sesión, la app queda sin sesión', () async {
      final store = InMemoryTokenStore(
        const SessionTokens(
          accessToken: 'acceso-viejo',
          refreshToken: 'sesion.secreto-1',
        ),
      );
      final container = ProviderContainer.test(
        overrides: [
          apiBaseUrlProvider.overrideWithValue('http://api.test'),
          tokenStoreProvider.overrideWithValue(store),
        ],
      );
      final api = container.read(memoriesApiProvider);
      api.dio.httpClientAdapter = FakeHttpAdapter(
        (request) async => request.path.endsWith('/refresh')
            ? apiError(401, 'invalid_refresh_token')
            : apiError(401, 'access_token_expired'),
      );
      container.listen(sessionProvider, (_, _) {});
      await pumpEventQueue();
      expect(container.read(sessionProvider), SessionStatus.signedIn);

      // Endpoint con token: vence, la renovación falla y la sesión se cierra.
      await expectLater(
        api.getAuthApi().changePasswordApiV1AuthPasswordChangePost(
          changePasswordRequest: ChangePasswordRequest(
            (b) => b
              ..currentPassword = 'clave-actual'
              ..newPassword = 'clave-nueva-1',
          ),
        ),
        throwsA(isA<DioException>()),
      );

      expect(container.read(sessionProvider), SessionStatus.signedOut);
      expect(store.tokens, isNull);
    });
  });

  group('apiBaseOptions', () {
    test('en web manda la cookie de sesión (withCredentials)', () {
      final options = apiBaseOptions(baseUrl: 'http://api.test', isWeb: true);

      // El adaptador web de dio lee extra['withCredentials'] en cada
      // petición; sin eso el navegador no guarda ni envía la cookie.
      expect(options.extra['withCredentials'], isTrue);
    });

    test('en Android no lo necesita: el token viaja en el cuerpo', () {
      final options = apiBaseOptions(baseUrl: 'http://api.test', isWeb: false);

      expect(options.extra.containsKey('withCredentials'), isFalse);
    });

    test(
      'una petición del cliente generado lleva withCredentials y secure',
      () async {
        final adapter = FakeHttpAdapter((_) async => jsonReply(204));
        final dio = Dio(apiBaseOptions(baseUrl: 'http://api.test', isWeb: true))
          ..httpClientAdapter = adapter;

        await MemoriesApi(dio: dio).getAuthApi().logoutApiV1AuthLogoutPost();

        final extra = adapter.requests.single.extra;
        expect(extra['withCredentials'], isTrue);
        expect(extra.containsKey('secure'), isTrue);
      },
    );
  });

  group('apiBaseUrlProvider', () {
    test('sin --dart-define, leer la URL falla en vez de usar un valor por '
        'defecto', () {
      final container = ProviderContainer.test();

      // En los tests no se pasa API_BASE_URL: la validación debe cortar.
      // Riverpod 3 entrega el error envuelto en un ProviderException.
      expect(
        () => container.read(apiBaseUrlProvider),
        throwsA(
          isA<ProviderException>().having(
            (error) => error.exception,
            'exception',
            isA<StateError>(),
          ),
        ),
      );
    });
  });
}
