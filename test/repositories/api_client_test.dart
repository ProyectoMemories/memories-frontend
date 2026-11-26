import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/app_config.dart';
import 'package:memories/repositories/api_client.dart';

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
