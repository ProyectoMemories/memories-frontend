import 'memory_photo.dart';

/// Un recuerdo: la unidad central del producto.
class Memory {
  const Memory({
    required this.id,
    required this.title,
    required this.momentDate,
    required this.photos,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final DateTime momentDate;
  final String? description;
  final List<MemoryPhoto> photos;
  final DateTime createdAt;
  final DateTime updatedAt;

  MemoryPhoto get portada => photos.first;

  bool get tieneDescripcion => (description ?? '').trim().isNotEmpty;
}

/// Una pagina de recuerdos, tal y como la devuelve la API.
class PagedMemories {
  const PagedMemories({
    required this.items,
    required this.total,
    required this.page,
    required this.size,
    required this.pages,
  });

  final List<Memory> items;
  final int total;
  final int page;
  final int size;
  final int pages;

  bool get hayMas => page < pages;

  static const PagedMemories empty = PagedMemories(
    items: <Memory>[],
    total: 0,
    page: 1,
    size: 20,
    pages: 0,
  );
}
