import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:memories/repositories/api_error.dart';
import 'package:memories/repositories/session/refresh_gate.dart';
import 'package:memories/repositories/session/token_store.dart';

void main() {
  const tokens = SessionTokens(accessToken: 'acceso-nuevo');

  test('dos renovaciones a la vez = una sola llamada', () async {
    final gate = RefreshGate();
    final release = Completer<SessionTokens>();
    var calls = 0;
    Future<SessionTokens> refresh() {
      calls++;
      return release.future;
    }

    final first = gate.run(refresh);
    final second = gate.run(refresh);
    release.complete(tokens);

    expect(await Future.wait([first, second]), [tokens, tokens]);
    expect(calls, 1);
  });

  test('cuando termina, la siguiente vuelve a renovar', () async {
    final gate = RefreshGate();
    var calls = 0;
    Future<SessionTokens> refresh() async {
      calls++;
      return tokens;
    }

    await gate.run(refresh);
    await gate.run(refresh);

    expect(calls, 2);
  });

  test('un error llega a todos los que esperaban y libera la puerta', () async {
    final gate = RefreshGate();
    final release = Completer<SessionTokens>();

    final first = gate.run(() => release.future);
    final second = gate.run(() => release.future);
    release.completeError(const ApiError(ApiErrorCode.invalidRefreshToken));

    await expectLater(first, throwsA(isA<ApiError>()));
    await expectLater(second, throwsA(isA<ApiError>()));
    expect(await gate.run(() async => tokens), tokens);
  });

  test('idle espera la renovación en curso, aunque falle', () async {
    final gate = RefreshGate();
    final release = Completer<SessionTokens>();
    final renewal = gate.run(() => release.future);
    var idle = false;
    final waiting = gate.idle().then((_) => idle = true);

    await pumpEventQueue();
    expect(idle, isFalse);

    release.completeError(const ApiError(ApiErrorCode.network));
    await expectLater(renewal, throwsA(isA<ApiError>()));
    await waiting;
    expect(idle, isTrue);
  });

  test('idle sin renovación en curso termina enseguida', () async {
    await RefreshGate().idle();
  });
}
