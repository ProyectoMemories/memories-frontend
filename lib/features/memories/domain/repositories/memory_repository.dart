import 'dart:typed_data';

import '../entities/calendar_day.dart';
import '../entities/memory.dart';
import '../entities/memory_photo.dart';
import '../entities/revive_result.dart';

/// Contrato de datos de los recuerdos.
///
/// Las pantallas y los controladores dependen de esto, no de Dio ni de la forma
/// del JSON.
abstract class MemoryRepository {
  Future<PagedMemories> listar({
    int pagina = 1,
    int tamano = 20,
    DateTime? desde,
    DateTime? hasta,
    String? busqueda,
  });

  Future<Memory> obtener(String id);

  Future<Memory> crear({
    required String titulo,
    required DateTime fecha,
    required List<String> idsDeFotos,
    String? descripcion,
  });

  Future<Memory> actualizar({
    required String id,
    String? titulo,
    DateTime? fecha,
    String? descripcion,
    bool borrarDescripcion = false,
  });

  Future<void> borrar(String id);

  /// Sube una fotografia y la deja lista para asociarla a un recuerdo.
  ///
  /// Se trabaja con bytes y no con un archivo del sistema: en web no existe
  /// `dart:io`, y la app tiene que ser la misma en movil y en navegador.
  Future<MemoryPhoto> subirFoto({
    required Uint8List bytes,
    required String nombre,
    required String tipoDeContenido,
  });

  Future<Memory> anadirFotos({
    required String memoryId,
    required List<String> idsDeFotos,
  });

  Future<Memory> quitarFoto({
    required String memoryId,
    required String photoId,
  });

  Future<List<CalendarDay>> calendario({required int ano, required int mes});

  Future<ReviveResult> revivir();
}
