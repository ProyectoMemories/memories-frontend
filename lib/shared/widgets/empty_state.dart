import 'package:flutter/material.dart';

/// Pantalla vacia con una salida.
///
/// Una lista vacia nunca se deja en blanco: siempre dice que falta y que hacer.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icono,
    required this.titulo,
    required this.mensaje,
    this.accion,
    super.key,
  });

  final IconData icono;
  final String titulo;
  final String mensaje;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icono, size: 56, color: tema.colorScheme.primary),
            const SizedBox(height: 16),
            Text(titulo, style: tema.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyMedium,
            ),
            if (accion != null) ...<Widget>[
              const SizedBox(height: 24),
              accion!,
            ],
          ],
        ),
      ),
    );
  }
}
