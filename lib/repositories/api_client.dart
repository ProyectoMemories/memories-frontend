import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memories_api/memories_api.dart';

import '../app_config.dart';

/// Opciones de dio para hablar con la API.
///
/// En web, `withCredentials` hace que el navegador guarde y envíe la cookie
/// `HttpOnly` del token de renovación (design.md §5). El adaptador web de dio
/// lo lee de `extra` en cada petición, y dio junta este `extra` con el que
/// pone el cliente generado.
BaseOptions apiBaseOptions({required String baseUrl, required bool isWeb}) {
  return BaseOptions(
    baseUrl: baseUrl,
    extra: {if (isWeb) 'withCredentials': true},
  );
}

/// Cliente generado desde el OpenAPI del backend (D57, D79).
///
/// Solo los repositorios lo leen: las vistas y los ViewModels nunca ven sus
/// tipos (CLAUDE.md §7).
final memoriesApiProvider = Provider<MemoriesApi>((ref) {
  final options = apiBaseOptions(
    baseUrl: ref.watch(apiBaseUrlProvider),
    isWeb: kIsWeb,
  );
  return MemoriesApi(dio: Dio(options));
});
