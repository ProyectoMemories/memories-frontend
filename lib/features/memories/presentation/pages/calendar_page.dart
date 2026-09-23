import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/date_format.dart';
import '../../../../shared/widgets/async_view.dart';
import '../../domain/entities/calendar_day.dart';
import '../../domain/entities/memory.dart';
import '../providers/memory_providers.dart';
import '../widgets/month_grid.dart';

/// Vista calendario (capacidad CP-08): los recuerdos ordenados por fecha.
class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  static const String ruta = '/calendar';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime mes = ref.watch(mesDelCalendarioProvider);
    final AsyncValue<List<CalendarDay>> dias = ref.watch(calendarioProvider);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => ref.read(mesDelCalendarioProvider.notifier).state =
                    DateTime(mes.year, mes.month - 1),
              ),
              Text(
                Fechas.mesYAno(mes),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => ref.read(mesDelCalendarioProvider.notifier).state =
                    DateTime(mes.year, mes.month + 1),
              ),
            ],
          ),
        ),
        Expanded(
          child: AsyncView<List<CalendarDay>>(
            valor: dias,
            alReintentar: () => ref.invalidate(calendarioProvider),
            datos: (List<CalendarDay> recuento) => SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  MonthGrid(
                    mes: mes,
                    dias: recuento,
                    onDiaSeleccionado: (DateTime dia) =>
                        _mostrarDia(context, ref, dia),
                  ),
                  const SizedBox(height: 16),
                  if (recuento.isEmpty)
                    const Text('Ningun recuerdo este mes.')
                  else
                    Text(
                      '${recuento.fold<int>(0, (int suma, CalendarDay d) => suma + d.count)} '
                      'recuerdos este mes',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _mostrarDia(BuildContext context, WidgetRef ref, DateTime dia) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => _RecuerdosDelDia(dia: dia),
    );
  }
}

class _RecuerdosDelDia extends ConsumerWidget {
  const _RecuerdosDelDia({required this.dia});

  final DateTime dia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Memory>> recuerdos = ref.watch(recuerdosDelDiaProvider(dia));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              Fechas.largo(dia),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: AsyncView<List<Memory>>(
                valor: recuerdos,
                datos: (List<Memory> lista) => ListView.builder(
                  shrinkWrap: true,
                  itemCount: lista.length,
                  itemBuilder: (BuildContext context, int indice) {
                    final Memory memory = lista[indice];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          memory.portada.url,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image_outlined),
                        ),
                      ),
                      title: Text(memory.title),
                      subtitle: Text('${memory.photos.length} fotografias'),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/memories/${memory.id}');
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
