import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../controllers/auth_controller.dart';

/// Composicion de dependencias de la aplicacion.
///
/// Equivale al `dependencies.py` del backend: todo el cableado en un archivo.
final Provider<TokenStorage> tokenStorageProvider = Provider<TokenStorage>(
  (Ref ref) => TokenStorage(),
);

final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((Ref ref) {
  final TokenStorage almacen = ref.watch(tokenStorageProvider);
  return ApiClient(
    tokenStorage: almacen,
    onSessionExpired: () async {
      await almacen.clear();
      ref.read(authControllerProvider.notifier).sesionExpirada();
    },
  );
});

final Provider<Dio> dioProvider = Provider<Dio>(
  (Ref ref) => ref.watch(apiClientProvider).dio,
);

final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>((Ref ref) {
  return AuthRepositoryImpl(
    remoto: AuthRemoteDataSource(ref.watch(dioProvider)),
    almacen: ref.watch(tokenStorageProvider),
  );
});

/// Estado de la sesion: null = nadie ha iniciado sesion.
final AsyncNotifierProvider<AuthController, AppUser?> authControllerProvider =
    AsyncNotifierProvider<AuthController, AppUser?>(AuthController.new);
