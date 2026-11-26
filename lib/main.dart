import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_config.dart';
import 'views/app_router.dart';
import 'views/theme/app_theme.dart';

void main() {
  validateApiBaseUrl(apiBaseUrlFromEnvironment);
  runApp(const ProviderScope(child: MemoriesApp()));
}

class MemoriesApp extends ConsumerWidget {
  const MemoriesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Memories',
      theme: buildAppTheme(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
