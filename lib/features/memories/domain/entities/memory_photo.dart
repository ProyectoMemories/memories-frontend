/// Una fotografia de un recuerdo.
///
/// `url` puede ser una URL firmada del almacenamiento (MinIO o S3) o un
/// endpoint de la API: al cliente le da igual, siempre recibe una direccion que
/// puede abrir.
class MemoryPhoto {
  const MemoryPhoto({
    required this.id,
    required this.url,
    required this.contentType,
    required this.sizeBytes,
    required this.position,
    this.memoryId,
  });

  final String id;
  final String url;
  final String contentType;
  final int sizeBytes;
  final int position;
  final String? memoryId;

  bool get estaAsociada => memoryId != null;
}
