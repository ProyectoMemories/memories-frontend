import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/repositories/api_error.dart';
import 'package:memories/repositories/auth_repository.dart';
import 'package:memories/view_models/auth/check_email_view_model.dart';

import 'session_notifier_test.dart' show FakeAuthRepository;

void main() {
  late FakeAuthRepository repository;
  late ProviderContainer container;
  late List<String> resent;

  setUp(() {
    repository = FakeAuthRepository();
    resent = [];
    repository.onResendVerification = (email) async => resent.add(email);
    container = ProviderContainer.test(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    container.listen(checkEmailViewModelProvider, (_, _) {});
  });

  CheckEmailViewModel viewModel() =>
      container.read(checkEmailViewModelProvider.notifier);
  CheckEmailState state() => container.read(checkEmailViewModelProvider);

  test('reenvía al correo sin espacios y avisa que se reenvió', () async {
    expect(await viewModel().resend(' ana@ejemplo.pe '), isTrue);
    expect(resent, ['ana@ejemplo.pe']);
    expect(state().errorMessage, isNull);
  });

  test(
    'sin correo o con uno mal escrito, lo marca y no llama a la API',
    () async {
      expect(await viewModel().resend(''), isFalse);
      expect(state().emailError, 'Escribe tu correo.');

      expect(await viewModel().resend('ana'), isFalse);
      expect(state().emailError, 'Escribe un correo válido.');
      expect(resent, isEmpty);
    },
  );

  test('demasiados intentos: cuántos segundos esperar', () async {
    repository.onResendVerification = (_) async => throw const ApiError(
      ApiErrorCode.tooManyRequests,
      retryAfter: Duration(seconds: 30),
    );
    expect(await viewModel().resend('ana@ejemplo.pe'), isFalse);
    expect(state().errorMessage, 'Demasiados intentos. Prueba en 30 segundos.');
    expect(state().isResending, isFalse);
  });
}
