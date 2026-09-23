import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/date_format.dart';
import '../../domain/entities/calendar_day.dart';
import '../../domain/entities/memory.dart';
import '../../domain/entities/memory_photo.dart';
import '../../domain/entities/revive_result.dart';
import '../models/memory_dto.dart';

/// Unico sitio que habla con los endpoints de recuerdos y fotografias.
class MemoryRemoteDataSource {
  const MemoryRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PagedMemories> listar({
    int pagina = 1,
    int tamano = 20,
    DateTime? desde,
    DateTime? hasta,
    String? busqueda,
  }) async {
    return _envolver(() async {
      final Response<dynamic> respuesta = await _dio.get<dynamic>(
        ApiEndpoints.memories,
        queryParameters: <String, dynamic>{
          'page': pagina,
          'size': tamano,
          if (desde != null) 'date_from': Fechas.iso(desde),
          if (hasta != null) 'date_to': Fechas.iso(hasta),
          if (busqueda != null && busqueda.trim().isNotEmpty) 'q': busqueda.trim(),
        },
      );
      return MemoryDto.paginaDesdeJson(respuesta.data as Map<String, dynamic>);
    });
  }

  Future<Memory> obtener(String id) {
    return _envolver(() async {
      final Response<dynamic> respuesta =
          await _dio.get<dynamic>(ApiEndpoints.memory(id));
      return MemoryDto.desdeJson(respuesta.data as Map<String, dynamic>);
    });
  }

  Future<Memory> crear({
    required String titulo,
    required DateTime fecha,
    required List<String> idsDeFotos,
    String? descripcion,
  }) {
    return _envolver(() async {
      final Response<dynamic> respuesta = await _dio.post<dynamic>(
        ApiEndpoints.memories,
        data: <String, dynamic>{
          'title': titulo,
          'moment_date': Fechas.iso(fecha),
          'photo_ids': idsDeFotos,
          if (descripcion != null && descripcion.trim().isNotEmpty)
            'description': descripcion.trim(),
        },
      );
      return MemoryDto.desdeJson(respuesta.data as Map<String, dynamic>);
    });
  }

  Future<Memory> actualizar({
    required String id,
    String? titulo,
    DateTime? fecha,
    String? descripcion,
    bool borrarDescripcion = false,
  }) {
    return _envolver(() async {
      final Response<dynamic> respuesta = await _dio.patch<dynamic>(
        ApiEndpoints.memory(id),
        data: <String, dynamic>{
          if (titulo != null) 'title': titulo,
          if (fecha != null) 'moment_date': Fechas.iso(fecha),
          if (descripcion != null) 'description': descripcion,
          if (borrarDescripcion) 'clear_description': true,
        },
      );
      return MemoryDto.desdeJson(respuesta.data as Map<String, dynamic>);
    });
  }

  Future<void> borrar(String id) {
    return _envolver(() async {
      await _dio.delete<dynamic>(ApiEndpoints.memory(id));
    });
  }

  Future<MemoryPhoto> subirFoto({
    required Uint8List bytes,
    required String nombre,
    required String tipoDeContenido,
  }) {
    return _envolver(() async {
      final List<String> partes = tipoDeContenido.split('/');
      final FormData formulario = FormData.fromMap(<String, dynamic>{
        'file': MultipartFile.fromBytes(
          bytes,
          filename: nombre,
          contentType: MediaType(
            partes.first,
            partes.length > 1 ? partes[1] : 'jpeg',
          ),
        ),
      });
      final Response<dynamic> respuesta = await _dio.post<dynamic>(
        ApiEndpoints.photos,
        data: formulario,
      );
      return MemoryDto.fotoDesdeJson(respuesta.data as Map<String, dynamic>);
    });
  }

  Future<Memory> anadirFotos({
    required String memoryId,
    required List<String> idsDeFotos,
  }) {
    return _envolver(() async {
      final Response<dynamic> respuesta = await _dio.post<dynamic>(
        ApiEndpoints.memoryPhotos(memoryId),
        data: <String, dynamic>{'photo_ids': idsDeFotos},
      );
      return MemoryDto.desdeJson(respuesta.data as Map<String, dynamic>);
    });
  }

  Future<Memory> quitarFoto({
    required String memoryId,
    required String photoId,
  }) {
    return _envolver(() async {
      final Response<dynamic> respuesta = await _dio.delete<dynamic>(
        ApiEndpoints.memoryPhoto(memoryId, photoId),
      );
      return MemoryDto.desdeJson(respuesta.data as Map<String, dynamic>);
    });
  }

  Future<List<CalendarDay>> calendario({required int ano, required int mes}) {
    return _envolver(() async {
      final Response<dynamic> respuesta = await _dio.get<dynamic>(
        ApiEndpoints.calendar,
        queryParameters: <String, dynamic>{'year': ano, 'month': mes},
      );
      return MemoryDto.calendarioDesdeJson(respuesta.data as Map<String, dynamic>);
    });
  }

  Future<ReviveResult> revivir() {
    return _envolver(() async {
      final Response<dynamic> respuesta =
          await _dio.get<dynamic>(ApiEndpoints.revive);
      return MemoryDto.revivirDesdeJson(respuesta.data as Map<String, dynamic>);
    });
  }

  /// Traduce cualquier fallo de red al error de la aplicacion, una sola vez.
  Future<T> _envolver<T>(Future<T> Function() operacion) async {
    try {
      return await operacion();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
