import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Aviso inferior del mockup ("Correo reenviado"). El estilo sale del
/// `snackBarTheme` del tema; aquí solo va el ícono.
void showAppToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: AppColors.toastIcon,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}
