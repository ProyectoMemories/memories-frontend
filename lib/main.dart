import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app_config.dart';
import 'views/app_router.dart';
import 'views/theme/app_theme.dart';

void main() {
  validateApiBaseUrl(apiBaseUrlFromEnvironment);
  // En web, rutas reales (/login) y no con '#' (/#/login): los enlaces de
  // los correos llegan como /verify-email?token=... (D65, D73). En Android no
  // hace nada.
  usePathUrlStrategy();
  runApp(const ProviderScope(child: MemoriesApp()));
}

class MemoriesApp extends ConsumerWidget {
  const MemoriesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Memories',
      theme: buildAppTheme(),
      // La app es solo en español: así también salen en español los textos
      // de Material (calendario, menús, avisos de accesibilidad).
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
