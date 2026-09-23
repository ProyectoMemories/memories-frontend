import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

/// Punto de entrada.
///
/// Arranque:
///   flutter run --dart-define-from-file=env/dev.json
///   flutter run -d chrome --dart-define-from-file=env/dev.json
///   flutter run -d emulator-5554 --dart-define-from-file=env/dev.android.json
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Nombres de meses y dias en espanol.
  await initializeDateFormatting('es');

  runApp(const ProviderScope(child: MemoriesApp()));
}
