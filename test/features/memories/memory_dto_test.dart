import 'package:flutter_test/flutter_test.dart';
import 'package:memories_app/features/memories/data/models/memory_dto.dart';
import 'package:memories_app/features/memories/domain/entities/memory.dart';
import 'package:memories_app/features/memories/domain/entities/revive_result.dart';

/// Lo que devuelve la API, tal cual.
Map<String, dynamic> recuerdoJson() => <String, dynamic>{
      'id': '11111111-1111-1111-1111-111111111111',
      'title': 'Viaje a Paracas',
      'moment_date': '2026-01-15',
      'description': 'El dia que vimos los delfines.',
      'photos': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': '22222222-2222-2222-2222-222222222222',
          'url': 'http://localhost:9010/memories-photos/foto.png',
          'content_type': 'image/png',
          'size_bytes': 1024,
          'position': 0,
          'memory_id': '11111111-1111-1111-1111-111111111111',
        },
      ],
      'created_at': '2026-01-16T10:00:00+00:00',
      'updated_at': '2026-01-16T10:00:00+00:00',
    };

void main() {
  test('traduce un recuerdo con su fotografia', () {
    final Memory memory = MemoryDto.desdeJson(recuerdoJson());

    expect(memory.title, 'Viaje a Paracas');
    expect(memory.momentDate, DateTime(2026, 1, 15));
    expect(memory.photos, hasLength(1));
    expect(memory.portada.url, contains('foto.png'));
    expect(memory.tieneDescripcion, isTrue);
  });

  test('un recuerdo sin descripcion no finge tenerla', () {
    final Map<String, dynamic> json = recuerdoJson()..['description'] = null;
    expect(MemoryDto.desdeJson(json).tieneDescripcion, isFalse);
  });

  test('traduce una pagina de recuerdos', () {
    final PagedMemories pagina = MemoryDto.paginaDesdeJson(<String, dynamic>{
      'items': <Map<String, dynamic>>[recuerdoJson()],
      'total': 1,
      'page': 1,
      'size': 20,
      'pages': 1,
    });

    expect(pagina.items, hasLength(1));
    expect(pagina.hayMas, isFalse);
  });

  test('traduce el motivo de revivir', () {
    expect(MotivoRevivir.desdeApi('on_this_day'), MotivoRevivir.enEsteDia);
    expect(MotivoRevivir.desdeApi('random'), MotivoRevivir.alAzar);
    expect(MotivoRevivir.desdeApi('none'), MotivoRevivir.ninguno);
  });
}
