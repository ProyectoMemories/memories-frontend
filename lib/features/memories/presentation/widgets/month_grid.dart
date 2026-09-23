import 'package:flutter/material.dart';

import '../../../../core/utils/date_format.dart';
import '../../domain/entities/calendar_day.dart';

/// Rejilla de un mes, escrita a mano.
///
/// Un calendario de un mes son treinta lineas de Dart; una dependencia externa
/// para esto es una dependencia que mantener sin motivo.
class MonthGrid extends StatelessWidget {
  const MonthGrid({
    required this.mes,
    required this.dias,
    required this.onDiaSeleccionado,
    super.key,
  });

  final DateTime mes;
  final List<CalendarDay> dias;
  final ValueChanged<DateTime> onDiaSeleccionado;

  static const List<String> _cabeceras = <String>['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final Map<int, int> recuentoPorDia = <int, int>{
      for (final CalendarDay dia in dias) dia.day.day: dia.count,
    };

    final int diasDelMes = DateTime(mes.year, mes.month + 1, 0).day;
    // DateTime.weekday: lunes = 1. La rejilla empieza en lunes.
    final int huecoInicial = DateTime(mes.year, mes.month, 1).weekday - 1;
    final int celdas = huecoInicial + diasDelMes;
    final DateTime hoy = Fechas.soloDia(DateTime.now());

    return Column(
      children: <Widget>[
        Row(
          children: _cabeceras
              .map(
                (String letra) => Expanded(
                  child: Center(
                    child: Text(letra, style: tema.textTheme.labelMedium),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: celdas,
          itemBuilder: (BuildContext context, int indice) {
            if (indice < huecoInicial) {
              return const SizedBox.shrink();
            }
            final int numeroDeDia = indice - huecoInicial + 1;
            final DateTime fecha = DateTime(mes.year, mes.month, numeroDeDia);
            final int recuento = recuentoPorDia[numeroDeDia] ?? 0;
            final bool esHoy = Fechas.mismoDia(fecha, hoy);

            return InkWell(
              onTap: recuento == 0 ? null : () => onDiaSeleccionado(fecha),
              borderRadius: BorderRadius.circular(8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: recuento > 0
                      ? tema.colorScheme.primaryContainer
                      : Colors.transparent,
                  border: esHoy
                      ? Border.all(color: tema.colorScheme.primary, width: 2)
                      : null,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('$numeroDeDia'),
                      if (recuento > 0)
                        Text(
                          '$recuento',
                          style: tema.textTheme.labelSmall?.copyWith(
                            color: tema.colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
