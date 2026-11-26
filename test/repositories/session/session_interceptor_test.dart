import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/repositories/api_error.dart';
import 'package:memories/repositories/session/session_interceptor.dart';
import 'package:memories/repositories/session/token_store.dart';

import '../fake_http_adapter.dart';

/// Cómo marca el cliente generado un endpoint que pide el token de acceso.
final _secured = Options(
  extra: {
    'secure': [
      {'type': 'http', 'scheme': 'bearer', 'name': 'HTTPBearer'},
    ],
  },
);

final _public = Options(extra: {'secure': <Map<String, String>>[]});

void main() {
  late Dio dio;
  late FakeHttpAdapter adapter;
  late InMemoryTokenStore store;
  late int refreshCalls;
  late Future<SessionTokens> Function() refresh;
  late int expiredCalls;

  /// Responde 200 si llega el token nuevo y 401 vencido con cualquier otro.
  Future<ResponseBody> acceptsOnly(String token, RequestOptions request) async {
    return request.headers['Authorization'] == 'Bearer $token'
        ? jsonReply(200, {'ok': true})
        : apiError(401, 'access_token_expired');
  }

  setUp(() {
    store = InMemoryTokenStore(
      const SessionTokens(
        accessToken: 'acceso-viejo',
        refreshToken: 'sesion.secreto-1',
      ),
    );
    refreshCalls = 0;
    expiredCalls = 0;
    refresh = () async {
      const tokens = SessionTokens(
        accessToken: 'acceso-nuevo',
        refreshToken: 'sesion.secreto-2',
      );
      await store.save(tokens);
      return tokens;
    };
    adapter = FakeHttpAdapter(
      (request) => acceptsOnly('acceso-nuevo', request),
    );
    dio = Dio(BaseOptions(baseUrl: 'http://api.test'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(
      SessionInterceptor(
        dio: dio,
        tokenStore: store,
        refresh: () {
          refreshCalls++;
          return refresh();
        },
        onSessionExpired: () => expiredCalls++,
      ),
    );
  });

  test('pone el token solo en los endpoints que lo piden', () async {
    adapter.handler = (_) async => jsonReply(200, {'ok': true});

    await dio.post<void>('/privado', options: _secured);
    await dio.post<void>('/publico', options: _public);

    expect(adapter.requests[0].headers['Authorization'], 'Bearer acceso-viejo');
    expect(adapter.requests[1].headers.containsKey('Authorization'), isFalse);
  });

  test('token vencido: renueva, repite y la persona no nota nada', () async {
    final response = await dio.post<Object>('/privado', options: _secured);

    expect(response.statusCode, 200);
    expect(refreshCalls, 1);
    expect(adapter.requests, hasLength(2));
    expect(
      adapter.requests.last.headers['Authorization'],
      'Bearer acceso-nuevo',
    );
  });

  test(
    'dos 401 a la vez = una sola renovación (si no, la API ve reuso)',
    () async {
      final release = Completer<void>();
      final original = refresh;
      refresh = () async {
        await release.future;
        return original();
      };

      final first = dio.post<Object>('/uno', options: _secured);
      final second = dio.post<Object>('/dos', options: _secured);
      // Deja que las dos fallen y lleguen al interceptor antes de renovar.
      await pumpEventQueue();
      release.complete();

      final responses = await Future.wait([first, second]);

      expect(refreshCalls, 1);
      expect(responses.map((r) => r.statusCode), [200, 200]);
    },
  );

  test('si otra petición ya renovó, repite sin volver a renovar', () async {
    // '/lenta' sale con el token viejo y su respuesta tarda; mientras, '/uno'
    // falla, renueva y termina. Cuando '/lenta' recibe su 401 ya hay un token
    // nuevo guardado.
    final slowAnswer = Completer<void>();
    // dio repite con el mismo RequestOptions: se copia la cabecera al salir.
    final slowTokensSent = <Object?>[];
    adapter.handler = (request) async {
      if (request.path == '/lenta') {
        slowTokensSent.add(request.headers['Authorization']);
        await slowAnswer.future;
      }
      return acceptsOnly('acceso-nuevo', request);
    };

    final slow = dio.post<Object>('/lenta', options: _secured);
    await pumpEventQueue();
    await dio.post<Object>('/uno', options: _secured);
    slowAnswer.complete();
    final response = await slow;

    expect(response.statusCode, 200);
    expect(refreshCalls, 1);
    expect(slowTokensSent, ['Bearer acceso-viejo', 'Bearer acceso-nuevo']);
  });

  test('sesión revocada: borra los tokens y avisa que se cerró', () async {
    refresh = () async =>
        throw const ApiError(ApiErrorCode.invalidRefreshToken);

    await expectLater(
      dio.post<Object>('/privado', options: _secured),
      throwsA(isA<DioException>()),
    );

    expect(store.tokens, isNull);
    expect(expiredCalls, 1);
  });

  test('sin conexión al renovar: falla pero mantiene la sesión', () async {
    refresh = () async => throw const ApiError(ApiErrorCode.network);

    await expectLater(
      dio.post<Object>('/privado', options: _secured),
      throwsA(isA<DioException>()),
    );

    expect(store.tokens?.refreshToken, 'sesion.secreto-1');
    expect(expiredCalls, 0);
  });

  test('otro 401 (no vencido) pasa tal cual, sin renovar', () async {
    adapter.handler = (_) async => apiError(401, 'not_authenticated');

    await expectLater(
      dio.post<Object>('/privado', options: _secured),
      throwsA(isA<DioException>()),
    );
    expect(refreshCalls, 0);
  });

  test(
    'si la petición repetida vuelve a vencer, no renueva en bucle',
    () async {
      adapter.handler = (_) async => apiError(401, 'access_token_expired');

      await expectLater(
        dio.post<Object>('/privado', options: _secured),
        throwsA(isA<DioException>()),
      );
      expect(refreshCalls, 1);
      expect(adapter.requests, hasLength(2));
    },
  );
}
