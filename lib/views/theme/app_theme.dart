import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tema de la app con los tokens y medidas del mockup (design.md §3).
ThemeData buildAppTheme() {
  const colorScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.divider,
    error: AppColors.danger,
    onError: AppColors.onPrimary,
  );

  final fieldRadius = BorderRadius.circular(14);
  OutlineInputBorder fieldBorder(Color color, [double width = 1.5]) =>
      OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: color, width: width),
      );

  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: AppFonts.text,
    textTheme: _textTheme,
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      hintStyle: _textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
      enabledBorder: fieldBorder(AppColors.border),
      focusedBorder: fieldBorder(AppColors.primary, 2),
      errorBorder: fieldBorder(AppColors.danger),
      focusedErrorBorder: fieldBorder(AppColors.danger, 2),
      errorStyle: _textTheme.labelSmall?.copyWith(color: AppColors.danger),
      helperStyle: _textTheme.labelSmall?.copyWith(
        color: AppColors.textSecondary,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size.fromHeight(54)),
        shape: WidgetStatePropertyAll(buttonShape),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.pressed)
              ? AppColors.primaryPressed
              : AppColors.primary,
        ),
        foregroundColor: const WidgetStatePropertyAll(AppColors.onPrimary),
        textStyle: WidgetStatePropertyAll(_textTheme.labelLarge),
        elevation: const WidgetStatePropertyAll(0),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size.fromHeight(54)),
        shape: WidgetStatePropertyAll(buttonShape),
        side: const WidgetStatePropertyAll(
          BorderSide(color: AppColors.primary, width: 2),
        ),
        foregroundColor: const WidgetStatePropertyAll(AppColors.primary),
        textStyle: WidgetStatePropertyAll(_textTheme.labelLarge),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        // 44 px: tamaño mínimo para tocar (design:accessibility-review).
        minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
        foregroundColor: const WidgetStatePropertyAll(AppColors.primary),
        textStyle: WidgetStatePropertyAll(
          _textTheme.labelLarge?.copyWith(fontSize: 14),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.toast,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      contentTextStyle: _textTheme.bodyMedium?.copyWith(
        color: AppColors.surface,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),
  );
}

/// Tipografía del mockup: Fraunces para títulos y Nunito Sans para el resto.
const _textTheme = TextTheme(
  // "Memories" en Iniciar sesión.
  displaySmall: TextStyle(
    fontFamily: AppFonts.titles,
    fontSize: 38,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.38,
    color: AppColors.textPrimary,
  ),
  // Títulos de Inicio y Perfil.
  headlineMedium: TextStyle(
    fontFamily: AppFonts.titles,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  ),
  // Títulos de los avisos de pantalla completa ("Revisa tu correo").
  headlineSmall: TextStyle(
    fontFamily: AppFonts.titles,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.28,
    color: AppColors.textPrimary,
  ),
  // Nombres en tarjetas.
  titleMedium: TextStyle(
    fontFamily: AppFonts.titles,
    fontSize: 19,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  ),
  // Texto que escribe la persona en los campos.
  bodyLarge: TextStyle(
    fontFamily: AppFonts.text,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  ),
  // Subtítulos y párrafos.
  bodyMedium: TextStyle(
    fontFamily: AppFonts.text,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  ),
  // Botones.
  labelLarge: TextStyle(
    fontFamily: AppFonts.text,
    fontSize: 16,
    fontWeight: FontWeight.w800,
  ),
  // Etiquetas de campo en mayúsculas.
  labelMedium: TextStyle(
    fontFamily: AppFonts.text,
    fontSize: 13,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.26,
    color: AppColors.label,
  ),
  // Ayudas, errores y la barra inferior.
  labelSmall: TextStyle(
    fontFamily: AppFonts.text,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
  ),
);
