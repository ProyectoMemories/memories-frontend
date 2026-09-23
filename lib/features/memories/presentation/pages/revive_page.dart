import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/layout/breakpoints.dart';
import '../../../../shared/widgets/async_view.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../domain/entities/memory.dart';
import '../../domain/entities/revive_result.dart';
import '../providers/memory_providers.dart';
import '../widgets/memory_card.dart';

/// Volver a descubrir recuerdos (capacidad CP-05).
class RevivePage extends ConsumerWidget {
  const RevivePage({super.key});

  static const String ruta = '/revive';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ReviveResult> propuesta = ref.watch(revivirProvider);

    return AsyncView<ReviveResult>(
      valor: propuesta,
      alReintentar: () => ref.invalidate(revivirProvider),
      datos: (ReviveResult resultado) {
        if (!resultado.hayAlgo) {
          return const EmptyState(
            icono: Icons.history_toggle_off_outlined,
            titulo: 'Todavia no hay nada que revivir',
            mensaje: 'Cuando guardes recuerdos, aqui volveran a aparecer.',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(revivirProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(
                resultado.motivo.titulo,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                resultado.motivo == MotivoRevivir.enEsteDia
                    ? 'Esto pasaba un dia como hoy.'
                    : 'Una vuelta al azar por lo que has guardado.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Breakpoints.columnas(context),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.78,
                ),
                itemCount: resultado.memories.length,
                itemBuilder: (BuildContext context, int indice) {
                  final Memory memory = resultado.memories[indice];
                  return MemoryCard(
                    memory: memory,
                    onTap: () => context.push('/memories/${memory.id}'),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
