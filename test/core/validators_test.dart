import 'package:flutter_test/flutter_test.dart';
import 'package:memories_app/core/utils/date_format.dart';
import 'package:memories_app/core/utils/validators.dart';

void main() {
  group('Validaciones de correo', () {
    test('acepta un correo normal', () {
      expect(Validaciones.correo('victor@memories.app'), isNull);
    });

    test('rechaza uno vacio y uno mal escrito', () {
      expect(Validaciones.correo(''), isNotNull);
      expect(Validaciones.correo('victor@'), isNotNull);
      expect(Validaciones.correo('victor.memories.app'), isNotNull);
    });
  });

  group('Validaciones de contrasena', () {
    test('exige la longitud minima del backend', () {
      expect(Validaciones.contrasena('1234567'), isNotNull);
      expect(Validaciones.contrasena('12345678'), isNull);
    });
  });

  group('Formato de fechas', () {
    test('iso da el formato que espera la API', () {
      expect(Fechas.iso(DateTime(2026, 1, 5)), '2026-01-05');
    });

    test('mismoDia ignora la hora', () {
      expect(
        Fechas.mismoDia(DateTime(2026, 1, 5, 23, 59), DateTime(2026, 1, 5, 0, 1)),
        isTrue,
      );
    });
  });
}
