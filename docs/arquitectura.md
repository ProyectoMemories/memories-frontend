# Arquitectura de la app

Mapa para responder "donde vive esto". El producto esta en
[docs/product/prd-resumen.md](product/prd-resumen.md); el porque de cada
decision, en [docs/adr/](adr/).

---

## 1. Capas

```
presentation  →  domain  ←  data
  widgets          entidades      DTOs, Dio,
  controladores    contratos      implementaciones
```

`presentation` y `data` dependen de `domain`. `domain` no depende de nadie: ni
Flutter, ni Dio, ni Riverpod. Es la misma regla que en el backend.

| Carpeta | Puede importar | Jamas importa |
|---|---|---|
| `domain` | Dart puro | Flutter, Dio, Riverpod |
| `data` | `domain`, Dio, `core/network` | widgets |
| `presentation` | `domain`, Riverpod, Flutter | Dio, DTOs |

## 2. Estructura

```
lib/
├── main.dart               arranque (fechas en espanol + ProviderScope)
├── app.dart                MaterialApp.router y pantalla de carga inicial
├── core/
│   ├── config/             AppConfig: URL de la API por --dart-define
│   ├── network/            ApiClient (Dio + interceptores), ApiEndpoints, ApiException
│   ├── storage/            TokenStorage (almacen seguro del sistema)
│   ├── router/             app_router.dart (go_router) y home_shell.dart
│   ├── theme/              Material 3 a partir de un color semilla
│   └── utils/              fechas y validaciones
├── shared/
│   ├── layout/             Breakpoints y AdaptiveScaffold
│   └── widgets/            AppButton, AppTextField, AsyncView, EmptyState
└── features/
    ├── auth/               sesion y perfil
    └── memories/           recuerdos, fotografias, calendario y revivir
```

## 3. Reglas que no se negocian

- **Ninguna URL fuera de `core/network/api_endpoints.dart`.** Es la leccion de
  CRIS, donde centralizar los endpoints evito decenas de rutas sueltas.
- **Las pantallas no llaman a la API.** Solo los repositorios lo hacen; las
  pantallas hablan con su controlador.
- **Un controlador no conoce widgets**; una pantalla no conoce Dio.
- **`domain` es Dart puro.** Si necesitas importar Flutter ahi, algo esta en la
  capa equivocada.
- **Nada de `dart:io`** en codigo compartido: rompe la web
  ([ADR 0004](adr/0004-un-solo-codigo-para-movil-y-web.md)).

## 4. Sesion

1. `TokenStorage` guarda los dos tokens en el almacen seguro del sistema.
2. `ApiClient` anade el de acceso a cada peticion.
3. Ante un 401, renueva **una sola vez** (varias peticiones fallidas a la vez
   comparten la misma renovacion) y reintenta la original.
4. Si la renovacion falla, limpia los tokens y avisa a `AuthController`, que
   vacia el estado; `go_router` reacciona y lleva al inicio de sesion.

Al arrancar, `AuthController.build()` intenta recuperar la sesion guardada
pidiendo el perfil. Mientras tanto, `app.dart` muestra la pantalla de carga: asi
no se ve el formulario de inicio de sesion durante medio segundo para que
desaparezca enseguida.

## 5. Errores

Todo fallo de red pasa por `ApiException.fromDio`, que entiende el formato de
error del backend (`{"error": {"code", "message", ...}}`) y deja un mensaje
listo para mostrar. `AsyncView` lo pinta igual en todas las pantallas.

## 6. Lo que no esta hecho

- **Modo sin conexion.** Los repositorios estan preparados (`data/` es el unico
  sitio a tocar), pero no hay cache local.
- **Miniaturas.** El listado descarga la imagen completa: el backend todavia no
  genera versiones reducidas.
- **Gestion de fotografias desde la edicion.** Se pueden anadir y quitar por API,
  pero la pantalla de edicion solo cambia texto y fecha.
- **Albumes compartidos.** No existen en el backend (pendiente P17 del PRD).
