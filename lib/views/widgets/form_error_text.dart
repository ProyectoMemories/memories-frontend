import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Error de un envío que no es de un campo. `liveRegion` hace que el lector
/// de pantalla lo anuncie apenas aparece; anuncia [announcement] (si se da)
/// y no el texto visible, que en la cuenta regresiva cambia cada segundo.
class FormErrorText extends StatelessWidget {
  const FormErrorText(this.message, {super.key, this.announcement});

  final String message;
  final String? announcement;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: announcement ?? message,
      child: ExcludeSemantics(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: AppColors.danger),
        ),
      ),
    );
  }
}
