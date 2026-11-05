# Memories — App (Flutter)

App de Memories para Android y web, con un solo código Flutter. iOS queda fuera
del MVP.

Producto, decisiones, reglas de negocio, requisitos y arquitectura viven en
Google Drive, carpeta "Proyecto Recuerdos". Aquí solo va lo necesario para
levantar y probar la app. Las reglas para trabajar con Claude Code están en
[CLAUDE.md](CLAUDE.md) y los specs en `specs/`.

El código anterior, escrito con el PRD v3.0, se conserva en el tag
`legacy-prd-v3.0`.

## Requisitos

- **Flutter 3.47.9, canal `stable`** (Dart 3.13.7). Comprueba con
  `flutter --version`; si tienes otra, `flutter channel stable` y
  `flutter upgrade`.
- Chrome, para la versión web.
- Android Studio, solo para el SDK y el emulador de Android.
- El backend (`memories-backend`) levantado según su README, para usar la API.

## Cómo levantarla

```powershell
flutter pub get
```

La URL de la API entra al compilar con `--dart-define=API_BASE_URL=...`; sin
ella, la app no arranca.

**Web** (siempre en el puerto 3000: es el único origen que acepta la API):

```powershell
flutter run -d chrome --web-port 3000 --dart-define=API_BASE_URL=http://localhost:8001
```

**Android** (el emulador llega a tu PC por `10.0.2.2`, no por `localhost`):

```powershell
flutter emulators --launch <id>   # lista los ids con: flutter emulators
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8001
```

## Cómo probarla

```powershell
dart format --set-exit-if-changed .   # formato
flutter analyze                       # análisis estático
flutter test                          # pruebas
```

## Cómo contribuir

1. Crea tu rama desde `main`: `feat/…`, `fix/…`, `chore/…` o `docs/…`.
2. Si es una funcionalidad nueva, primero el spec en `specs/<feature>/`.
3. Abre un Pull Request hacia `main` y completa la plantilla.
4. Revisa tu propio diff y, cuando el CI pase, fusiona tu PR.

`main` está protegido: no acepta push directo, force push ni borrado.
