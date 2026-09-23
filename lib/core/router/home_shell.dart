import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/layout/adaptive_scaffold.dart';

/// Envoltorio de las pantallas principales.
///
/// La misma navegacion sirve para movil (barra inferior) y para pantallas
/// anchas (carril lateral): eso lo resuelve `AdaptiveScaffold`.
class HomeShell extends StatelessWidget {
  const HomeShell({required this.indice, required this.child, super.key});

  final int indice;
  final Widget child;

  static const List<DestinoNavegacion> destinos = <DestinoNavegacion>[
    DestinoNavegacion(
      etiqueta: 'Recuerdos',
      icono: Icons.photo_library_outlined,
      iconoActivo: Icons.photo_library,
      ruta: '/memories',
    ),
    DestinoNavegacion(
      etiqueta: 'Calendario',
      icono: Icons.calendar_month_outlined,
      iconoActivo: Icons.calendar_month,
      ruta: '/calendar',
    ),
    DestinoNavegacion(
      etiqueta: 'Revivir',
      icono: Icons.auto_awesome_outlined,
      iconoActivo: Icons.auto_awesome,
      ruta: '/revive',
    ),
    DestinoNavegacion(
      etiqueta: 'Perfil',
      icono: Icons.person_outline,
      iconoActivo: Icons.person,
      ruta: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      destinos: destinos,
      indiceActual: indice,
      titulo: destinos[indice].etiqueta,
      onDestinoSeleccionado: (int nuevo) => context.go(destinos[nuevo].ruta),
      botonFlotante: indice == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/memories/new'),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo'),
            )
          : null,
      child: child,
    );
  }
}
