import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/api_error.dart';
import '../../repositories/auth_repository.dart';

enum VerifyEmailResult {
  verified,

  /// Vencido, ya usado o sin token: hay que pedir otro (HU-03).
  linkInvalid,
}

/// Verifica la cuenta apenas se abre `/verify-email?token=` (HU-03).
///
/// Mientras carga, el estado es `AsyncLoading`. Un fallo de conexión queda
/// como `AsyncError` y se reintenta con [retry].
class VerifyEmailViewModel extends AsyncNotifier<VerifyEmailResult> {
  VerifyEmailViewModel(this._token);

  final String? _token;

  @override
  Future<VerifyEmailResult> build() async {
    final token = _token;
    if (token == null || token.isEmpty) return VerifyEmailResult.linkInvalid;
    try {
      await ref.read(authRepositoryProvider).verifyEmail(token);
      return VerifyEmailResult.verified;
    } on ApiError catch (error) {
      if (error.code == ApiErrorCode.expiredToken ||
          error.code == ApiErrorCode.invalidToken) {
        return VerifyEmailResult.linkInvalid;
      }
      rethrow;
    }
  }

  /// Vuelve a intentar después de un fallo de conexión. Verificar dos veces
  /// no cambia nada en la API.
  void retry() => ref.invalidateSelf();
}

final verifyEmailViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<VerifyEmailViewModel, VerifyEmailResult, String?>(
      VerifyEmailViewModel.new,
      // Sin reintentos solos: el reintento lo decide la persona.
      retry: (_, _) => null,
    );
