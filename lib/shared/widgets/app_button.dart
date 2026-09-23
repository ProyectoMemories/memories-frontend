import 'package:flutter/material.dart';

/// Boton principal con estado de carga.
///
/// Mientras hay una operacion en curso se deshabilita y muestra el progreso:
/// asi nadie pulsa dos veces "guardar" y crea dos recuerdos iguales.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.texto,
    required this.onPressed,
    this.cargando = false,
    this.icono,
    super.key,
  });

  final String texto;
  final VoidCallback? onPressed;
  final bool cargando;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const FilledButton(
        onPressed: null,
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (icono == null) {
      return FilledButton(onPressed: onPressed, child: Text(texto));
    }

    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icono),
      label: Text(texto),
    );
  }
}
