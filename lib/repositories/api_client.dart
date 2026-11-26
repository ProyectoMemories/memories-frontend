import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memories_api/memories_api.dart';

import '../app_config.dart';

/// Cliente generado desde el OpenAPI del backend (D57, D79).
///
/// Solo los repositorios lo leen: las vistas y los ViewModels nunca ven sus
/// tipos (CLAUDE.md §7).
final memoriesApiProvider = Provider<MemoriesApi>(
  (ref) => MemoriesApi(basePathOverride: ref.watch(apiBaseUrlProvider)),
);
