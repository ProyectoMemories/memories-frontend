import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Casilla del mockup ("Acepto la política de privacidad"): cuadro de 24 px
/// con el texto al lado, y el error debajo. Toda la fila se puede tocar.
class AppCheckboxRow extends StatelessWidget {
  const AppCheckboxRow({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.errorText,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          container: true,
          checked: value,
          enabled: enabled,
          hint: errorText,
          child: InkWell(
            onTap: enabled ? () => onChanged(!value) : null,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: value ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(7),
                        border: value
                            ? null
                            : Border.all(
                                color: hasError
                                    ? AppColors.danger
                                    : AppColors.border,
                                width: 1.5,
                              ),
                      ),
                      child: value
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: AppColors.onPrimary,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.45,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (errorText case final error?)
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: ExcludeSemantics(
              child: Text(
                error,
                style: textTheme.labelSmall?.copyWith(color: AppColors.danger),
              ),
            ),
          ),
      ],
    );
  }
}
