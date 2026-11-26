import 'package:flutter/painting.dart';

/// Colores del mockup "Recuerdos 4.0" (design.md §3). Ninguna pantalla
/// escribe un color suelto: todo sale de aquí o del tema.
abstract final class AppColors {
  static const background = Color(0xFFF4ECDF);
  static const surface = Color(0xFFFFFBF4);
  static const primary = Color(0xFF7A2E2A);
  static const primaryPressed = Color(0xFF5E2220);
  static const onPrimary = Color(0xFFFFFBF4);
  static const textPrimary = Color(0xFF2B211B);
  static const textSecondary = Color(0xFF6B5B4E);
  static const label = Color(0xFF5A4A3E);
  static const border = Color(0xFFDCCDB8);
  static const divider = Color(0xFFE7DAC6);
  static const iconTile = Color(0xFFEADDC9);
  static const progressTrack = Color(0xFFE3D3BC);
  static const toast = Color(0xFF2B211B);
  static const toastIcon = Color(0xFFE2A93B);
  static const danger = Color(0xFFA3261F);
}

/// Familias declaradas en `pubspec.yaml` (D79).
abstract final class AppFonts {
  /// Títulos: Fraunces.
  static const titles = 'Fraunces';

  /// Texto: Nunito Sans.
  static const text = 'NunitoSans';
}
