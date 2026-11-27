import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../theme/app_colors.dart';

/// Avisa al lector de pantalla que hay campos con error: los mensajes bajo
/// cada campo no se anuncian solos.
void announceFieldErrors(BuildContext context) {
  SemanticsService.sendAnnouncement(
    View.of(context),
    'Revisa los campos marcados.',
    Directionality.of(context),
  );
}

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
