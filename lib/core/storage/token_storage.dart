import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda los tokens en el almacen seguro del sistema.
///
/// En movil son Keychain (iOS) y Keystore (Android). En web no existe tal cosa:
/// el paquete cae a un almacen del navegador, que es mas expuesto. Por eso el
/// token de acceso dura poco y el de refresco rota en cada uso
/// (ver el ADR 0003 del backend).
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _accessTokenKey = 'memories.access_token';
  static const String _refreshTokenKey = 'memories.refresh_token';

  final FlutterSecureStorage _storage;

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<bool> get hasSession async => (await readRefreshToken()) != null;
}
