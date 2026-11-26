import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Botón principal del mockup. Mientras [isLoading] muestra que espera y no
/// acepta otro toque (HU-01).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isLoading ? '$label, cargando' : null,
      excludeSemantics: isLoading,
      button: true,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        // Sin esto, el botón deshabilitado se vería gris mientras carga.
        style: isLoading
            ? FilledButton.styleFrom(
                disabledBackgroundColor: AppColors.primary,
                disabledForegroundColor: AppColors.onPrimary,
              )
            : null,
        child: isLoading
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.onPrimary,
                ),
              )
            : Text(label),
      ),
    );
  }
}

/// Botón con borde del mockup ("Crear cuenta").
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: onPressed, child: Text(label));
  }
}
