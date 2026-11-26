import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memories_api/memories_api.dart';

import '../app_config.dart';
import 'auth_repository.dart';
import 'session/refresh_gate.dart';
import 'session/session_expired_signal.dart';
import 'session/session_interceptor.dart';
import 'session/token_store.dart';

/// Opciones de dio para hablar con la API.
///
/// Los tiempos de espera son propios para que una regeneración del cliente
/// no los cambie, y holgados para el emulador o una red móvil lenta.
///
/// En web, `withCredentials` hace que el navegador guarde y envíe la cookie
/// `HttpOnly` del token de renovación (design.md §5). El adaptador web de dio
/// lo lee de `extra` en cada petición, y dio junta este `extra` con el que
/// pone el cliente generado.
BaseOptions apiBaseOptions({required String baseUrl, required bool isWeb}) {
  return BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    extra: {if (isWeb) 'withCredentials': true},
  );
}

/// Cliente generado desde el OpenAPI del backend (D57, D79).
///
/// Solo los repositorios lo leen: las vistas y los ViewModels nunca ven sus
/// tipos (CLAUDE.md §7).
final memoriesApiProvider = Provider<MemoriesApi>((ref) {
  final tokenStore = ref.watch(tokenStoreProvider);
  final dio = Dio(
    apiBaseOptions(baseUrl: ref.watch(apiBaseUrlProvider), isWeb: kIsWeb),
  );
  ref.onDispose(dio.close);
  // Lista vacía: sin los cuatro interceptores de autenticación que el
  // cliente generado agrega por defecto; el token lo pone SessionInterceptor.
  final api = MemoriesApi(dio: dio, interceptors: const []);
  // La renovación usa este mismo cliente. No se pide authRepositoryProvider:
  // depende de este provider y formaría un ciclo. Comparte el RefreshGate con
  // él, así las renovaciones siguen yendo de una en una.
  final refresher = AuthRepository(
    api: api.getAuthApi(),
    tokenStore: tokenStore,
    platform: currentClientPlatform,
    refreshGate: ref.watch(refreshGateProvider),
  );
  dio.interceptors.add(
    SessionInterceptor(
      dio: dio,
      tokenStore: tokenStore,
      refresh: refresher.refresh,
      onSessionExpired: () {
        if (ref.mounted) ref.read(sessionExpiredSignalProvider.notifier).emit();
      },
    ),
  );
  return api;
});
