import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Selector de fecha con el estilo de los campos del mockup ("Fecha de
/// nacimiento"): muestra DD/MM/AAAA y abre el calendario de Material.
class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.helperText,
    this.errorText,
    this.enabled = true,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final DateTime firstDate;
  final DateTime lastDate;
  final String? helperText;
  final String? errorText;
  final bool enabled;

  static String format(DateTime date) =>
      '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? lastDate,
      firstDate: firstDate,
      lastDate: lastDate,
      // Para una fecha de nacimiento, primero el año.
      initialDatePickerMode: DatePickerMode.year,
      helpText: label,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final current = value;
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Text(label.toUpperCase(), style: textTheme.labelMedium),
        ),
        const SizedBox(height: 6),
        Semantics(
          button: true,
          label: label,
          value: current == null ? 'Sin elegir' : format(current),
          hint: errorText,
          child: ExcludeSemantics(
            child: InkWell(
              onTap: enabled ? () => _pick(context) : null,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                constraints: const BoxConstraints(minHeight: 52),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: hasError ? AppColors.danger : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        current == null ? 'DD/MM/AAAA' : format(current),
                        style: textTheme.bodyLarge?.copyWith(
                          color: current == null
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (errorText ?? helperText case final text?) ...[
          const SizedBox(height: 6),
          ExcludeSemantics(
            excluding: hasError,
            child: Text(
              text,
              style: textTheme.labelSmall?.copyWith(
                color: hasError ? AppColors.danger : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
