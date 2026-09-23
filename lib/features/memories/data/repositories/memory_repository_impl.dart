import 'dart:typed_data';

import '../../domain/entities/calendar_day.dart';
import '../../domain/entities/memory.dart';
import '../../domain/entities/memory_photo.dart';
import '../../domain/entities/revive_result.dart';
import '../../domain/repositories/memory_repository.dart';
import '../datasources/memory_remote_data_source.dart';

/// Implementacion del contrato de recuerdos.
///
/// Hoy es una envoltura fina sobre la fuente remota, y esta bien que lo sea: el
/// dia que haya cache local o modo sin conexion, el cambio ocurre aqui y nadie
/// mas se entera.
class MemoryRepositoryImpl implements MemoryRepository {
  const MemoryRepositoryImpl(this._remoto);

  final MemoryRemoteDataSource _remoto;

  @override
  Future<PagedMemories> listar({
    int pagina = 1,
    int tamano = 20,
    DateTime? desde,
    DateTime? hasta,
    String? busqueda,
  }) {
    return _remoto.listar(
      pagina: pagina,
      tamano: tamano,
      desde: desde,
      hasta: hasta,
      busqueda: busqueda,
    );
  }

  @override
  Future<Memory> obtener(String id) => _remoto.obtener(id);

  @override
  Future<Memory> crear({
    required String titulo,
    required DateTime fecha,
    required List<String> idsDeFotos,
    String? descripcion,
  }) {
    return _remoto.crear(
      titulo: titulo,
      fecha: fecha,
      idsDeFotos: idsDeFotos,
      descripcion: descripcion,
    );
  }

  @override
  Future<Memory> actualizar({
    required String id,
    String? titulo,
    DateTime? fecha,
    String? descripcion,
    bool borrarDescripcion = false,
  }) {
    return _remoto.actualizar(
      id: id,
      titulo: titulo,
      fecha: fecha,
      descripcion: descripcion,
      borrarDescripcion: borrarDescripcion,
    );
  }

  @override
  Future<void> borrar(String id) => _remoto.borrar(id);

  @override
  Future<MemoryPhoto> subirFoto({
    required Uint8List bytes,
    required String nombre,
    required String tipoDeContenido,
  }) {
    return _remoto.subirFoto(
      bytes: bytes,
      nombre: nombre,
      tipoDeContenido: tipoDeContenido,
    );
  }

  @override
  Future<Memory> anadirFotos({
    required String memoryId,
    required List<String> idsDeFotos,
  }) {
    return _remoto.anadirFotos(memoryId: memoryId, idsDeFotos: idsDeFotos);
  }

  @override
  Future<Memory> quitarFoto({
    required String memoryId,
    required String photoId,
  }) {
    return _remoto.quitarFoto(memoryId: memoryId, photoId: photoId);
  }

  @override
  Future<List<CalendarDay>> calendario({required int ano, required int mes}) =>
      _remoto.calendario(ano: ano, mes: mes);

  @override
  Future<ReviveResult> revivir() => _remoto.revivir();
}
