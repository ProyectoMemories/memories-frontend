import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/memory.dart';
import '../../domain/repositories/memory_repository.dart';
import '../providers/memory_providers.dart';

/// Listado de recuerdos: carga, busqueda, paginacion y borrado.
class MemoriesController extends AsyncNotifier<PagedMemories> {
  String? _busqueda;
  DateTime? _desde;
  DateTime? _hasta;

  MemoryRepository get _repositorio => ref.read(memoryRepositoryProvider);

  String? get busquedaActual => _busqueda;

  @override
  Future<PagedMemories> build() => _cargar(pagina: 1);

  Future<PagedMemories> _cargar({required int pagina}) {
    return _repositorio.listar(
      pagina: pagina,
      desde: _desde,
      hasta: _hasta,
      busqueda: _busqueda,
    );
  }

  Future<void> refrescar() async {
    state = await AsyncValue.guard<PagedMemories>(() => _cargar(pagina: 1));
  }

  Future<void> buscar(String? texto) async {
    _busqueda = (texto ?? '').trim().isEmpty ? null : texto!.trim();
    state = const AsyncValue<PagedMemories>.loading();
    await refrescar();
  }

  Future<void> filtrarPorFechas({DateTime? desde, DateTime? hasta}) async {
    _desde = desde;
    _hasta = hasta;
    state = const AsyncValue<PagedMemories>.loading();
    await refrescar();
  }

  /// Carga la pagina siguiente y la anade a la lista que ya se esta viendo.
  Future<void> cargarMas() async {
    final PagedMemories? actual = state.valueOrNull;
    if (actual == null || !actual.hayMas || state.isLoading) {
      return;
    }
    final PagedMemories siguiente = await _cargar(pagina: actual.page + 1);
    state = AsyncValue<PagedMemories>.data(
      PagedMemories(
        items: <Memory>[...actual.items, ...siguiente.items],
        total: siguiente.total,
        page: siguiente.page,
        size: siguiente.size,
        pages: siguiente.pages,
      ),
    );
  }

  Future<void> borrar(String id) async {
    await _repositorio.borrar(id);
    // Se quita de la lista en memoria en vez de recargar todo: recargar
    // devolveria el scroll al principio.
    final PagedMemories? actual = state.valueOrNull;
    if (actual == null) {
      return;
    }
    final List<Memory> restantes =
        actual.items.where((Memory memory) => memory.id != id).toList();
    state = AsyncValue<PagedMemories>.data(
      PagedMemories(
        items: restantes,
        total: actual.total > 0 ? actual.total - 1 : 0,
        page: actual.page,
        size: actual.size,
        pages: actual.pages,
      ),
    );
  }
}
