import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memories/repositories/session/token_store.dart';

void main() {
  const tokens = SessionTokens(
    accessToken: 'acceso-1',
    refreshToken: 'sesion.secreto-1',
  );

  group('SecureTokenStore (Android)', () {
    setUp(() => FlutterSecureStorage.setMockInitialValues({}));

    test('sin sesión guardada, read devuelve null', () async {
      expect(
        await SecureTokenStore(const FlutterSecureStorage()).read(),
        isNull,
      );
    });

    test('los dos tokens sobreviven a reabrir la app', () async {
      await SecureTokenStore(const FlutterSecureStorage()).save(tokens);

      // Otra instancia: simula cerrar y volver a abrir la app (HU-06).
      final reopened = await SecureTokenStore(const FlutterSecureStorage())
          .read();

      expect(reopened?.accessToken, 'acceso-1');
      expect(reopened?.refreshToken, 'sesion.secreto-1');
    });

    test('save reemplaza los tokens anteriores (rotación)', () async {
      final store = SecureTokenStore(const FlutterSecureStorage());
      await store.save(tokens);
      await store.save(
        const SessionTokens(
          accessToken: 'acceso-2',
          refreshToken: 'sesion.secreto-2',
        ),
      );

      final stored = await SecureTokenStore(const FlutterSecureStorage())
          .read();

      expect(stored?.accessToken, 'acceso-2');
      expect(stored?.refreshToken, 'sesion.secreto-2');
    });

    test('clear borra los tokens del dispositivo', () async {
      final store = SecureTokenStore(const FlutterSecureStorage());
      await store.save(tokens);

      await store.clear();

      expect(await store.read(), isNull);
      expect(
        await SecureTokenStore(const FlutterSecureStorage()).read(),
        isNull,
      );
    });
  });

  group('MemoryTokenStore (web)', () {
    test('guarda solo el token de acceso, nunca el de renovación', () async {
      final store = MemoryTokenStore();

      await store.save(tokens);
      final stored = await store.read();

      // En web el de renovación vive en la cookie HttpOnly (CLAUDE.md §8).
      expect(stored?.accessToken, 'acceso-1');
      expect(stored?.refreshToken, isNull);
    });

    test('una instancia nueva empieza vacía: nada queda guardado', () async {
      await MemoryTokenStore().save(tokens);

      expect(await MemoryTokenStore().read(), isNull);
    });

    test('clear borra el token de acceso', () async {
      final store = MemoryTokenStore();
      await store.save(tokens);

      await store.clear();

      expect(await store.read(), isNull);
    });
  });
}
