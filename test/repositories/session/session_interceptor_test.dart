import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/repositories/api_error.dart';
import 'package:memories/repositories/session/refresh_gate.dart';
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

/// TokenStore cuyo `clear` falla, como un Keystore dañado.
class _BrokenClearTokenStore extends InMemoryTokenStore {
  _BrokenClearTokenStore(super.tokens);

  @override
  Future<void> clear() async => throw StateError('Keystore dañado');
}

void main() {
  late Dio dio;
  late FakeHttpAdapter adapter;
  late InMemoryTokenStore store;
  late int refreshCalls;
  late Future<SessionTokens> Function() refresh;
  late int expiredCalls;

  const oldTokens = SessionTokens(
    accessToken: 'acceso-viejo',
    refreshToken: 'sesion.secreto-1',
  );

  /// Responde 200 si llega [token] y 401 vencido con cualquier otro.
  Future<ResponseBody> acceptsOnly(String token, RequestOptions request) async {
    return request.headers['Authorization'] == 'Bearer $token'
        ? jsonReply(200, {'ok': true})
        : apiError(401, 'access_token_expired');
  }

  /// Arma el dio con el interceptor como lo hace `memoriesApiProvider`: la
  /// renovación pasa por un RefreshGate.
  void buildDio(InMemoryTokenStore tokenStore) {
    store = tokenStore;
    final gate = RefreshGate();
    dio = Dio(BaseOptions(baseUrl: 'http://api.test'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(
      SessionInterceptor(
        dio: dio,
        tokenStore: store,
        refresh: () => gate.run(() {
          refreshCalls++;
          return refresh();
        }),
        onSessionExpired: () => expiredCalls++,
      ),
    );
  }

  /// Hace la petición y devuelve el código que vería el repositorio.
  Future<ApiErrorCode> failureCode(String path) async {
    try {
      await dio.post<Object>(path, options: _secured);
    } on DioException catch (error) {
      return ApiError.fromDio(error).code;
    }
    fail('La petición debía fallar');
  }

  setUp(() {
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
    buildDio(InMemoryTokenStore(oldTokens));
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

  test('renovación rechazada: cierra la sesión y falla con '
      'invalidRefreshToken', () async {
    refresh = () async =>
        throw const ApiError(ApiErrorCode.invalidRefreshToken);

    expect(await failureCode('/privado'), ApiErrorCode.invalidRefreshToken);
    expect(store.tokens, isNull);
    expect(expiredCalls, 1);
  });

  test(
    'sin conexión al renovar: falla con network y mantiene la sesión',
    () async {
      refresh = () async => throw const ApiError(ApiErrorCode.network);

      expect(await failureCode('/privado'), ApiErrorCode.network);
      expect(store.tokens?.refreshToken, 'sesion.secreto-1');
      expect(expiredCalls, 0);
    },
  );

  test('not_authenticated con token (sesión revocada en otro dispositivo): '
      'cierra la sesión sin renovar', () async {
    adapter.handler = (_) async => apiError(401, 'not_authenticated');

    expect(await failureCode('/privado'), ApiErrorCode.notAuthenticated);
    expect(refreshCalls, 0);
    expect(store.tokens, isNull);
    expect(expiredCalls, 1);
  });

  test('not_authenticated sin token enviado no toca la sesión', () async {
    buildDio(InMemoryTokenStore());
    adapter.handler = (_) async => apiError(401, 'not_authenticated');

    expect(await failureCode('/privado'), ApiErrorCode.notAuthenticated);
    expect(expiredCalls, 0);
  });

  test('otros errores pasan tal cual, sin renovar', () async {
    adapter.handler = (_) async => apiError(403, 'account_suspended');

    expect(await failureCode('/privado'), ApiErrorCode.accountSuspended);
    expect(refreshCalls, 0);
    expect(expiredCalls, 0);
  });

  test(
    'si la petición repetida vuelve a vencer, no renueva en bucle',
    () async {
      adapter.handler = (_) async => apiError(401, 'access_token_expired');

      expect(await failureCode('/privado'), ApiErrorCode.accessTokenExpired);
      expect(refreshCalls, 1);
      expect(adapter.requests, hasLength(2));
    },
  );

  test('un 401 tardío después de cerrar sesión no renueva', () async {
    final slowAnswer = Completer<void>();
    adapter.handler = (request) async {
      await slowAnswer.future;
      return apiError(401, 'access_token_expired');
    };

    final late401 = failureCode('/privado');
    await pumpEventQueue();
    await store.clear();
    slowAnswer.complete();

    expect(await late401, ApiErrorCode.invalidRefreshToken);
    expect(refreshCalls, 0);
  });

  group('fallos inesperados (reportados, nunca dejan peticiones colgadas)', () {
    late List<FlutterErrorDetails> reported;

    setUp(() {
      reported = [];
      final previousOnError = FlutterError.onError;
      FlutterError.onError = reported.add;
      addTearDown(() => FlutterError.onError = previousOnError);
    });

    test('al renovar: falla con unknown y mantiene la sesión', () async {
      refresh = () async => throw StateError('falla inesperada');

      final codes = await Future.wait([
        failureCode('/uno'),
        failureCode('/dos'),
      ]).timeout(const Duration(seconds: 2));

      expect(codes, everyElement(ApiErrorCode.unknown));
      expect(reported, isNotEmpty);
      expect(reported.map((r) => r.exception), everyElement(isA<StateError>()));
      expect(store.tokens?.refreshToken, 'sesion.secreto-1');
    });

    test('al borrar los tokens: igual avisa que la sesión terminó', () async {
      buildDio(_BrokenClearTokenStore(oldTokens));
      refresh = () async =>
          throw const ApiError(ApiErrorCode.invalidRefreshToken);

      final code = await failureCode('/privado')
          .timeout(const Duration(seconds: 2));

      expect(code, ApiErrorCode.invalidRefreshToken);
      expect(expiredCalls, 1);
      expect(reported.single.exception, isA<StateError>());
    });
  });
}
