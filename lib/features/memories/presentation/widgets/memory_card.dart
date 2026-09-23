import 'package:flutter/material.dart';

import '../../../../core/utils/date_format.dart';
import '../../domain/entities/memory.dart';

/// Tarjeta de un recuerdo en el listado.
class MemoryCard extends StatelessWidget {
  const MemoryCard({
    required this.memory,
    required this.onTap,
    super.key,
  });

  final Memory memory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.network(
                    memory.portada.url,
                    fit: BoxFit.cover,
                    loadingBuilder: (
                      BuildContext context,
                      Widget hijo,
                      ImageChunkEvent? progreso,
                    ) {
                      if (progreso == null) {
                        return hijo;
                      }
                      return ColoredBox(
                        color: tema.colorScheme.surfaceContainerHighest,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (BuildContext context, Object error, StackTrace? _) {
                      return ColoredBox(
                        color: tema.colorScheme.surfaceContainerHighest,
                        child: const Center(child: Icon(Icons.broken_image_outlined)),
                      );
                    },
                  ),
                  if (memory.photos.length > 1)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Text(
                            '${memory.photos.length}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            memory.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: tema.textTheme.titleSmall,
          ),
          Text(
            Fechas.corto(memory.momentDate),
            style: tema.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
