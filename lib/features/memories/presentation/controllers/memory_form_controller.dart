import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/memory.dart';
import '../../domain/entities/memory_photo.dart';
import '../../domain/repositories/memory_repository.dart';
import '../providers/memory_providers.dart';

/// Estado del formulario de un recuerdo.
class MemoryFormState {
  const MemoryFormState({
    this.fotos = const <MemoryPhoto>[],
    this.subiendo = false,
    this.guardando = false,
    this.error,
  });

  final List<MemoryPhoto> fotos;
  final bool subiendo;
  final bool guardando;
  final String? error;

  bool get puedeGuardar => fotos.isNotEmpty && !subiendo && !guardando;

  MemoryFormState copiarCon({
    List<MemoryPhoto>? fotos,
    bool? subiendo,
    bool? guardando,
    String? error,
    bool limpiarError = false,
  }) {
    return MemoryFormState(
      fotos: fotos ?? this.fotos,
      subiendo: subiendo ?? this.subiendo,
      guardando: guardando ?? this.guardando,
      error: limpiarError ? null : (error ?? this.error),
    );
  }
}

/// Controla la subida de fotografias y el guardado del recuerdo.
///
/// Las fotos se suben mientras la persona escribe: cuando pulsa guardar, solo
/// queda enviar el texto y los identificadores.
class MemoryFormController extends Notifier<MemoryFormState> {
  MemoryRepository get _repositorio => ref.read(memoryRepositoryProvider);

  final ImagePicker _selector = ImagePicker();

  @override
  MemoryFormState build() => const MemoryFormState();

  void reiniciar({List<MemoryPhoto> fotosIniciales = const <MemoryPhoto>[]}) {
    state = MemoryFormState(fotos: fotosIniciales);
  }

  /// Abre la galeria y sube lo que se elija.
  Future<void> elegirYSubirFotos() async {
    state = state.copiarCon(subiendo: true, limpiarError: true);
    try {
      final List<XFile> elegidas = await _selector.pickMultiImage();
      if (elegidas.isEmpty) {
        state = state.copiarCon(subiendo: false);
        return;
      }

      final List<MemoryPhoto> subidas = <MemoryPhoto>[...state.fotos];
      for (final XFile archivo in elegidas) {
        // Bytes y no File: en web no existe dart:io y la app es la misma.
        final MemoryPhoto foto = await _repositorio.subirFoto(
          bytes: await archivo.readAsBytes(),
          nombre: archivo.name,
          tipoDeContenido: archivo.mimeType ?? _tipoPorExtension(archivo.name),
        );
        subidas.add(foto);
      }
      state = state.copiarCon(fotos: subidas, subiendo: false);
    } catch (error) {
      state = state.copiarCon(subiendo: false, error: _mensaje(error));
    }
  }

  void quitarFoto(String photoId) {
    state = state.copiarCon(
      fotos: state.fotos.where((MemoryPhoto foto) => foto.id != photoId).toList(),
    );
  }

  Future<Memory?> guardar({
    required String titulo,
    required DateTime fecha,
    String? descripcion,
    String? memoryIdAEditar,
  }) async {
    state = state.copiarCon(guardando: true, limpiarError: true);
    try {
      final Memory recuerdo;
      if (memoryIdAEditar == null) {
        recuerdo = await _repositorio.crear(
          titulo: titulo,
          fecha: fecha,
          descripcion: descripcion,
          idsDeFotos: state.fotos.map((MemoryPhoto foto) => foto.id).toList(),
        );
      } else {
        recuerdo = await _repositorio.actualizar(
          id: memoryIdAEditar,
          titulo: titulo,
          fecha: fecha,
          descripcion: descripcion,
          borrarDescripcion: (descripcion ?? '').trim().isEmpty,
        );
      }
      state = state.copiarCon(guardando: false);
      // La lista deja de ser valida: se recargara sola al volver a ella.
      ref.invalidate(memoriesControllerProvider);
      ref.invalidate(calendarioProvider);
      return recuerdo;
    } catch (error) {
      state = state.copiarCon(guardando: false, error: _mensaje(error));
      return null;
    }
  }

  static String _tipoPorExtension(String nombre) {
    final String minusculas = nombre.toLowerCase();
    if (minusculas.endsWith('.png')) {
      return 'image/png';
    }
    if (minusculas.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }

  static String _mensaje(Object error) {
    final String texto = error.toString();
    final int separador = texto.indexOf('): ');
    return separador == -1 ? texto : texto.substring(separador + 3);
  }
}
