import 'package:flutter/material.dart';

/// Tema de la aplicacion.
///
/// Material 3 con un color semilla: el resto de la paleta la deriva Flutter, en
/// claro y en oscuro, sin mantener dos listas de colores a mano.
///
/// Se usan solo APIs estables de ThemeData a proposito, para no atarse a una
/// version concreta de Flutter.
class AppTheme {
  const AppTheme._();

  static const Color seed = Color(0xFF4C6EF5);

  static ThemeData light() => _base(Brightness.light);

  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final ColorScheme colors = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
