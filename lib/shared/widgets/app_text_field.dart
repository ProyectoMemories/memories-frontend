import 'package:flutter/material.dart';

/// Campo de texto con etiqueta y validacion, igual en toda la aplicacion.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    required this.etiqueta,
    this.validador,
    this.esContrasena = false,
    this.tipoTeclado,
    this.lineas = 1,
    this.maximoCaracteres,
    this.textoAyuda,
    this.habilitado = true,
    super.key,
  });

  final TextEditingController controller;
  final String etiqueta;
  final String? Function(String?)? validador;
  final bool esContrasena;
  final TextInputType? tipoTeclado;
  final int lineas;
  final int? maximoCaracteres;
  final String? textoAyuda;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validador,
      obscureText: esContrasena,
      keyboardType: tipoTeclado,
      maxLines: esContrasena ? 1 : lineas,
      maxLength: maximoCaracteres,
      enabled: habilitado,
      decoration: InputDecoration(
        labelText: etiqueta,
        helperText: textoAyuda,
      ),
    );
  }
}
