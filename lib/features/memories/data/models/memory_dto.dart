import '../../domain/entities/calendar_day.dart';
import '../../domain/entities/memory.dart';
import '../../domain/entities/memory_photo.dart';
import '../../domain/entities/revive_result.dart';

/// Traduccion entre el JSON de la API y las entidades de dominio.
///
/// Escrita a mano y sin generadores de codigo: son cuatro objetos y asi
/// `flutter run` funciona recien clonado, sin pasar antes por build_runner.
class MemoryDto {
  const MemoryDto._();

  static MemoryPhoto fotoDesdeJson(Map<String, dynamic> json) {
    return MemoryPhoto(
      id: json['id'] as String,
      url: json['url'] as String,
      contentType: json['content_type'] as String,
      sizeBytes: (json['size_bytes'] as num).toInt(),
      position: (json['position'] as num).toInt(),
      memoryId: json['memory_id'] as String?,
    );
  }

  static Memory desdeJson(Map<String, dynamic> json) {
    final List<dynamic> fotos = (json['photos'] as List<dynamic>?) ?? <dynamic>[];
    return Memory(
      id: json['id'] as String,
      title: json['title'] as String,
      momentDate: DateTime.parse(json['moment_date'] as String),
      description: json['description'] as String?,
      photos: fotos
          .map((dynamic foto) => fotoDesdeJson(foto as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static PagedMemories paginaDesdeJson(Map<String, dynamic> json) {
    final List<dynamic> items = (json['items'] as List<dynamic>?) ?? <dynamic>[];
    return PagedMemories(
      items: items
          .map((dynamic item) => desdeJson(item as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      size: (json['size'] as num).toInt(),
      pages: (json['pages'] as num).toInt(),
    );
  }

  static List<CalendarDay> calendarioDesdeJson(Map<String, dynamic> json) {
    final List<dynamic> dias = (json['days'] as List<dynamic>?) ?? <dynamic>[];
    return dias.map((dynamic dia) {
      final Map<String, dynamic> mapa = dia as Map<String, dynamic>;
      return CalendarDay(
        day: DateTime.parse(mapa['day'] as String),
        count: (mapa['count'] as num).toInt(),
      );
    }).toList();
  }

  static ReviveResult revivirDesdeJson(Map<String, dynamic> json) {
    final List<dynamic> recuerdos =
        (json['memories'] as List<dynamic>?) ?? <dynamic>[];
    return ReviveResult(
      motivo: MotivoRevivir.desdeApi(json['reason'] as String),
      memories: recuerdos
          .map((dynamic item) => desdeJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
