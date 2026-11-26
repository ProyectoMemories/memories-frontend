import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Tokens de la sesión actual (D56).
class SessionTokens {
  const SessionTokens({required this.accessToken, this.refreshToken});

  /// Token de acceso de 15 minutos.
  final String accessToken;

  /// Token de renovación. Solo existe en Android: en web lo guarda el
  /// navegador en la cookie `HttpOnly` y el código no puede leerlo.
  final String? refreshToken;
}

/// Dónde viven los tokens de la sesión en el dispositivo (CLAUDE.md §8).
abstract interface class TokenStore {
  Future<SessionTokens?> read();
  Future<void> save(SessionTokens tokens);
  Future<void> clear();
}

/// Android: los dos tokens en el almacenamiento seguro del sistema (Keystore).
class SecureTokenStore implements TokenStore {
  SecureTokenStore(this._storage);

  static const _accessTokenKey = 'memories.access_token';
  static const _refreshTokenKey = 'memories.refresh_token';

  final FlutterSecureStorage _storage;

  // Cada petición lee el token: la copia en memoria evita ir al Keystore
  // en cada una.
  SessionTokens? _cached;

  @override
  Future<SessionTokens?> read() async {
    if (_cached != null) return _cached;
    final accessToken = await _storage.read(key: _accessTokenKey);
    if (accessToken == null) return null;
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    return _cached = SessionTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<void> save(SessionTokens tokens) async {
    await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
    // Con value null, el paquete borra la clave: no queda un token viejo.
    await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);
    _cached = tokens;
  }

  @override
  Future<void> clear() async {
    _cached = null;
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}

/// Web: el token de acceso solo en memoria; nada en `localStorage` ni en
/// `sessionStorage`. Al recargar la página se pierde y se pide otro con la
/// cookie.
class MemoryTokenStore implements TokenStore {
  String? _accessToken;

  @override
  Future<SessionTokens?> read() async {
    final accessToken = _accessToken;
    return accessToken == null ? null : SessionTokens(accessToken: accessToken);
  }

  @override
  Future<void> save(SessionTokens tokens) async {
    _accessToken = tokens.accessToken;
  }

  @override
  Future<void> clear() async {
    _accessToken = null;
  }
}

/// Elige el almacenamiento según la plataforma, sin `dart:io` (CLAUDE.md §7).
final tokenStoreProvider = Provider<TokenStore>(
  (ref) => kIsWeb
      ? MemoryTokenStore()
      : SecureTokenStore(const FlutterSecureStorage()),
);
