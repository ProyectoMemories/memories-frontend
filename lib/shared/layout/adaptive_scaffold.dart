import 'package:flutter/material.dart';

import 'breakpoints.dart';

/// Destino de navegacion de la aplicacion.
class DestinoNavegacion {
  const DestinoNavegacion({
    required this.etiqueta,
    required this.icono,
    required this.iconoActivo,
    required this.ruta,
  });

  final String etiqueta;
  final IconData icono;
  final IconData iconoActivo;
  final String ruta;
}

/// Envoltorio de todas las pantallas con navegacion principal.
///
/// En movil, barra inferior. En pantallas anchas, carril lateral. Es el mismo
/// widget: la app no se bifurca en dos versiones (RNF-05).
class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    required this.destinos,
    required this.indiceActual,
    required this.onDestinoSeleccionado,
    required this.child,
    this.titulo,
    this.acciones,
    this.botonFlotante,
    super.key,
  });

  final List<DestinoNavegacion> destinos;
  final int indiceActual;
  final ValueChanged<int> onDestinoSeleccionado;
  final Widget child;
  final String? titulo;
  final List<Widget>? acciones;
  final Widget? botonFlotante;

  @override
  Widget build(BuildContext context) {
    final bool ancha = Breakpoints.esAncha(context);

    final Widget contenido = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: Breakpoints.anchoMaximoContenido,
        ),
        child: child,
      ),
    );

    return Scaffold(
      appBar: titulo == null
          ? null
          : AppBar(title: Text(titulo!), actions: acciones),
      floatingActionButton: botonFlotante,
      body: ancha
          ? Row(
              children: <Widget>[
                NavigationRail(
                  selectedIndex: indiceActual,
                  onDestinationSelected: onDestinoSeleccionado,
                  labelType: NavigationRailLabelType.all,
                  destinations: destinos
                      .map(
                        (DestinoNavegacion destino) => NavigationRailDestination(
                          icon: Icon(destino.icono),
                          selectedIcon: Icon(destino.iconoActivo),
                          label: Text(destino.etiqueta),
                        ),
                      )
                      .toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: contenido),
              ],
            )
          : contenido,
      bottomNavigationBar: ancha
          ? null
          : NavigationBar(
              selectedIndex: indiceActual,
              onDestinationSelected: onDestinoSeleccionado,
              destinations: destinos
                  .map(
                    (DestinoNavegacion destino) => NavigationDestination(
                      icon: Icon(destino.icono),
                      selectedIcon: Icon(destino.iconoActivo),
                      label: destino.etiqueta,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
