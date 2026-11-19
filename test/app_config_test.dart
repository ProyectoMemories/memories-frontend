import 'package:flutter_test/flutter_test.dart';
import 'package:memories/app_config.dart';

void main() {
  group('validateApiBaseUrl', () {
    test('acepta una URL http o https', () {
      expect(
        validateApiBaseUrl('http://localhost:8001'),
        'http://localhost:8001',
      );
      expect(
        validateApiBaseUrl('https://api.ejemplo.pe'),
        'https://api.ejemplo.pe',
      );
    });

    test('rechaza la URL vacía (falta --dart-define)', () {
      expect(() => validateApiBaseUrl(''), throwsStateError);
    });

    test('rechaza una URL sin esquema http', () {
      expect(() => validateApiBaseUrl('localhost:8001'), throwsStateError);
      expect(() => validateApiBaseUrl('ftp://servidor'), throwsStateError);
    });
  });
}
