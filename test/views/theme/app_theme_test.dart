import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/views/theme/app_colors.dart';
import 'package:memories/views/theme/app_theme.dart';

void main() {
  final theme = buildAppTheme();

  test('los colores son los del mockup (design §3)', () {
    expect(AppColors.background, const Color(0xFFF4ECDF));
    expect(AppColors.primary, const Color(0xFF7A2E2A));
    expect(AppColors.textPrimary, const Color(0xFF2B211B));
    expect(AppColors.border, const Color(0xFFDCCDB8));
  });

  test('el ThemeData usa los tokens', () {
    expect(theme.scaffoldBackgroundColor, AppColors.background);
    expect(theme.colorScheme.primary, AppColors.primary);
    expect(theme.colorScheme.onPrimary, AppColors.onPrimary);
    expect(theme.colorScheme.surface, AppColors.surface);
    expect(theme.colorScheme.onSurface, AppColors.textPrimary);
    expect(theme.colorScheme.error, AppColors.danger);
    expect(theme.snackBarTheme.backgroundColor, AppColors.toast);
  });

  test('títulos en Fraunces y texto en Nunito Sans', () {
    expect(theme.textTheme.displaySmall?.fontFamily, AppFonts.titles);
    expect(theme.textTheme.headlineMedium?.fontFamily, AppFonts.titles);
    expect(theme.textTheme.bodyLarge?.fontFamily, AppFonts.text);
    expect(theme.textTheme.labelLarge?.fontFamily, AppFonts.text);
  });

  test('campos como en el mockup: borde de 1,5 px y radio 14', () {
    final border =
        theme.inputDecorationTheme.enabledBorder! as OutlineInputBorder;

    expect(border.borderSide.color, AppColors.border);
    expect(border.borderSide.width, 1.5);
    expect(border.borderRadius, BorderRadius.circular(14));
    expect(theme.inputDecorationTheme.fillColor, AppColors.surface);
  });

  test('botón principal de 54 px de alto y radio 16', () {
    final style = theme.filledButtonTheme.style!;

    expect(style.minimumSize?.resolve({}), const Size.fromHeight(54));
    expect(
      style.shape?.resolve({}),
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
    expect(style.backgroundColor?.resolve({}), AppColors.primary);
  });

  test('un botón principal desactivado se ve distinto del activo', () {
    final style = theme.filledButtonTheme.style!;

    expect(
      style.backgroundColor?.resolve({WidgetState.disabled}),
      isNot(AppColors.primary),
    );
  });

  test('las fuentes van empaquetadas, sin descargarse (D79)', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final path in [
      'assets/fonts/fraunces/Fraunces-Bold.ttf',
      'assets/fonts/fraunces/Fraunces-Medium.ttf',
      'assets/fonts/fraunces/Fraunces-MediumItalic.ttf',
      'assets/fonts/nunito_sans/NunitoSans-Regular.ttf',
      'assets/fonts/nunito_sans/NunitoSans-SemiBold.ttf',
      'assets/fonts/nunito_sans/NunitoSans-Bold.ttf',
      'assets/fonts/nunito_sans/NunitoSans-ExtraBold.ttf',
    ]) {
      expect((await rootBundle.load(path)).lengthInBytes, greaterThan(0));
    }
  });
}
