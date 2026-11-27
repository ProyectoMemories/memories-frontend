import 'package:flutter/material.dart';

/// Campo del mockup: etiqueta en mayúsculas arriba y ayuda o error abajo.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.helperText,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
    this.enabled = true,
    this.obscureText = false,
    this.suffix,
  });

  /// Texto de la etiqueta tal como se lee; se muestra en mayúsculas.
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // El lector de pantalla lee la etiqueta desde el campo, no dos veces.
        ExcludeSemantics(
          child: Text(label.toUpperCase(), style: textTheme.labelMedium),
        ),
        const SizedBox(height: 6),
        Semantics(
          label: label,
          child: TextField(
            controller: controller,
            enabled: enabled,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            onSubmitted: onSubmitted,
            style: textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: hint,
              helperText: helperText,
              errorText: errorText,
              errorMaxLines: 3,
              helperMaxLines: 3,
              suffixIcon: suffix,
            ),
          ),
        ),
      ],
    );
  }
}
