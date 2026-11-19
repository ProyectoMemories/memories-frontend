import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_config.dart';
import 'views/home_view.dart';

void main() {
  validateApiBaseUrl(apiBaseUrlFromEnvironment);
  runApp(const ProviderScope(child: MemoriesApp()));
}

class MemoriesApp extends StatelessWidget {
  const MemoriesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Memories', home: HomeView());
  }
}
