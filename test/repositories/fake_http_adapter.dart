import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:memories/repositories/session/token_store.dart';

/// Respuesta que devuelve el adaptador falso para una petición.
typedef FakeHandler = Future<ResponseBody> Function(RequestOptions request);

/// Adaptador de dio que no sale a la red: responde con [handler] y guarda
/// cada petición para revisarla en el test.
class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this.handler);

  FakeHandler handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

/// Respuesta JSON con el código HTTP y las cabeceras indicadas.
ResponseBody jsonReply(
  int status, [
  Object? body,
  Map<String, String> headers = const {},
]) {
  return ResponseBody.fromString(
    body == null ? '' : jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
      for (final entry in headers.entries) entry.key: [entry.value],
    },
  );
}

/// Error con el formato de la API: `{"code", "message"}`.
ResponseBody apiError(
  int status,
  String code, [
  Map<String, String> headers = const {},
]) => jsonReply(status, {'code': code, 'message': 'mensaje'}, headers);

/// Cuerpo de `login` y `refresh` (en web, sin `refresh_token`).
Map<String, Object> tokenBody(String accessToken, [String? refreshToken]) => {
  'access_token': accessToken,
  'token_type': 'bearer',
  'expires_in': 900,
  'refresh_token': ?refreshToken,
};

/// TokenStore en memoria que guarda los dos tokens, como Android, sin
/// depender del Keystore.
class InMemoryTokenStore implements TokenStore {
  InMemoryTokenStore([this.tokens]);

  SessionTokens? tokens;

  @override
  Future<SessionTokens?> read() async => tokens;

  @override
  Future<void> save(SessionTokens tokens) async => this.tokens = tokens;

  @override
  Future<void> clear() async => tokens = null;
}
