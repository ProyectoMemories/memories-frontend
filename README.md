# Memories — App

Aplicacion de [Memories](docs/product/prd-resumen.md) en Flutter: **un solo
codigo para movil y para web** (RNF-05).

Flutter · Dart · Riverpod · go_router · Dio.

La API vive en el repositorio `memories-backend`.

---

## Antes de empezar

Este repositorio contiene el codigo de la aplicacion (`lib/`, `test/`), pero
**no las carpetas de plataforma** (`android/`, `ios/`, `web/`), que las genera
Flutter. La primera vez:

```bash
flutter create . --org app.memories --project-name memories_app \
  --platforms=android,ios,web
flutter pub get
```

`flutter create .` sobre una carpeta existente **anade** lo que falta y respeta
`lib/`, `test/` y `pubspec.yaml`.

## Arrancar

Con el backend levantado (`docker compose up -d` en `memories-backend`):

```bash
# Web
flutter run -d chrome --dart-define-from-file=env/dev.json

# Escritorio o movil con el backend en localhost
flutter run --dart-define-from-file=env/dev.json

# Emulador de Android: localhost no es el host, es 10.0.2.2
flutter run --dart-define-from-file=env/dev.android.json
```

Nunca se escribe la URL de la API en el codigo: entra por
`--dart-define-from-file` y se lee en `lib/core/config/app_config.dart`.

## Trabajo diario

```bash
flutter test                 # pruebas
flutter analyze              # analisis estatico
dart format .                # formato
flutter build web --release  # compilado de web
flutter build apk --release  # compilado de Android
```

## Como esta organizado

```
lib/
├── core/        configuracion, red, almacenamiento, rutas, tema, utilidades
├── shared/      layout adaptativo y widgets comunes
└── features/<feature>/
    ├── domain/         entidades y contratos (sin Flutter ni Dio)
    ├── data/           DTOs, fuentes remotas e implementacion de los contratos
    └── presentation/   providers, controladores (ViewModels) y pantallas
```

Los `features` se llaman igual que los modulos del backend: abres las dos
carpetas y lees lo mismo.

Detalle en [docs/arquitectura.md](docs/arquitectura.md) y en
[docs/adr/](docs/adr/). Las reglas de trabajo, en [CLAUDE.md](CLAUDE.md).

## Pantallas

| Ruta | Que hace |
|---|---|
| `/login`, `/register` | Entrar y crear cuenta |
| `/memories` | Lista de recuerdos con busqueda |
| `/memories/new` | Crear: elegir fotos, titulo, fecha y descripcion |
| `/memories/:id` | Detalle, editar y borrar |
| `/calendar` | Recuerdos por dia del mes |
| `/revive` | Volver a descubrir recuerdos |
| `/profile` | Perfil y cerrar sesion |
