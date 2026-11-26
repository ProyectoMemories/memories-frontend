import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_text_field.dart';

/// Campo de contraseña con botón para mostrarla u ocultarla (design §7: el
/// mockup no dibuja este campo y se usa el mismo estilo de los demás).
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    required this.label,
    required this.controller,
    this.helperText,
    this.errorText,
    this.textInputAction,
    this.autofillHints = const [AutofillHints.password],
    this.onSubmitted,
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final String? helperText;
  final String? errorText;
  final TextInputAction? textInputAction;
  final Iterable<String> autofillHints;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      controller: widget.controller,
      hint: '••••••••',
      helperText: widget.helperText,
      errorText: widget.errorText,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      obscureText: _obscured,
      suffix: IconButton(
        tooltip: _obscured ? 'Mostrar contraseña' : 'Ocultar contraseña',
        color: AppColors.textSecondary,
        icon: Icon(
          _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
        onPressed: () => setState(() => _obscured = !_obscured),
      ),
    );
  }
}
