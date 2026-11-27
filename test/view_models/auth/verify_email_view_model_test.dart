import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/repositories/api_error.dart';
import 'package:memories/repositories/auth_repository.dart';
import 'package:memories/view_models/auth/verify_email_view_model.dart';

import 'session_notifier_test.dart' show FakeAuthRepository;

void main() {
  late FakeAuthRepository repository;
  late ProviderContainer container;
  late List<String> verified;

  setUp(() {
    repository = FakeAuthRepository();
    verified = [];
    repository.onVerifyEmail = (token) async => verified.add(token);
    container = ProviderContainer.test(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
  });

  Future<VerifyEmailResult> resultFor(String? token) {
    final provider = verifyEmailViewModelProvider(token);
    container.listen(provider, (_, _) {});
    return container.read(provider.future);
  }

  test('con un token válido, verifica la cuenta', () async {
    expect(await resultFor('token-1'), VerifyEmailResult.verified);
    expect(verified, ['token-1']);
  });

  test('vencido o ya usado: pide otro enlace', () async {
    repository.onVerifyEmail = (_) async =>
        throw const ApiError(ApiErrorCode.expiredToken);
    expect(await resultFor('viejo'), VerifyEmailResult.linkInvalid);

    repository.onVerifyEmail = (_) async =>
        throw const ApiError(ApiErrorCode.invalidToken);
    expect(await resultFor('falso'), VerifyEmailResult.linkInvalid);
  });

  test('sin token en el enlace: no llama a la API', () async {
    expect(await resultFor(null), VerifyEmailResult.linkInvalid);
    expect(await resultFor(''), VerifyEmailResult.linkInvalid);
    expect(verified, isEmpty);
  });

  test('sin conexión: queda en error, sin reintentos solos, y se puede '
      'reintentar', () async {
    var calls = 0;
    repository.onVerifyEmail = (_) async {
      calls++;
      throw const ApiError(ApiErrorCode.network);
    };
    final provider = verifyEmailViewModelProvider('token-1');
    container.listen(provider, (_, _) {});
    await expectLater(
      container.read(provider.future),
      throwsA(isA<ApiError>()),
    );

    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(calls, 1);

    repository.onVerifyEmail = (_) async {};
    container.read(provider.notifier).retry();
    expect(await container.read(provider.future), VerifyEmailResult.verified);
  });
}
