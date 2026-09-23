import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/date_format.dart';
import '../../../../shared/widgets/async_view.dart';
import '../../domain/entities/memory.dart';
import '../../domain/entities/memory_photo.dart';
import '../providers/memory_providers.dart';

class MemoryDetailPage extends ConsumerWidget {
  const MemoryDetailPage({required this.memoryId, super.key});

  final String memoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Memory> recuerdo = ref.watch(memoryDetailProvider(memoryId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuerdo'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Editar',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/memories/$memoryId/edit'),
          ),
          IconButton(
            tooltip: 'Borrar',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmarBorrado(context, ref),
          ),
        ],
      ),
      body: AsyncView<Memory>(
        valor: recuerdo,
        alReintentar: () => ref.invalidate(memoryDetailProvider(memoryId)),
        datos: (Memory memory) => ListView(
          children: <Widget>[
            SizedBox(
              height: 320,
              child: PageView.builder(
                itemCount: memory.photos.length,
                itemBuilder: (BuildContext context, int indice) {
                  final MemoryPhoto foto = memory.photos[indice];
                  return Image.network(
                    foto.url,
                    fit: BoxFit.cover,
                    errorBuilder: (BuildContext context, Object error, StackTrace? _) =>
                        const Center(child: Icon(Icons.broken_image_outlined)),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(memory.title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.event_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text(Fechas.largo(memory.momentDate)),
                      const SizedBox(width: 16),
                      const Icon(Icons.photo_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text('${memory.photos.length}'),
                    ],
                  ),
                  if (memory.tieneDescripcion) ...<Widget>[
                    const SizedBox(height: 24),
                    Text(
                      memory.description!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarBorrado(BuildContext context, WidgetRef ref) async {
    final bool? confirmado = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Borrar este recuerdo'),
        content: const Text(
          'Se borrara con todas sus fotografias. Esto no se puede deshacer.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );

    if (confirmado != true || !context.mounted) {
      return;
    }

    await ref.read(memoriesControllerProvider.notifier).borrar(memoryId);
    ref.invalidate(calendarioProvider);
    if (context.mounted) {
      context.go('/memories');
    }
  }
}
