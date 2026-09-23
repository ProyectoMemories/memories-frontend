# ADR 0004 — Un solo codigo para movil y web

- Estado: aceptada
- Fecha: 2026-09-22

## Contexto

El RNF-05 pide desplegar en movil y en web **sin una segunda version del
codigo**. Flutter lo permite, pero no lo regala: hay tres sitios donde un
proyecto se parte en dos sin querer.

## Decision

1. **Archivos por bytes, nunca `dart:io`.** En web no existe `File`. La foto
   viaja como `Uint8List` desde `image_picker` hasta el repositorio
   (`subirFoto({required Uint8List bytes, ...})`). Ninguna capa importa
   `dart:io`.
2. **Un solo diseno adaptativo, no dos pantallas.** `Breakpoints` +
   `AdaptiveScaffold`: barra inferior por debajo de 600 px, carril lateral por
   encima, y el contenido limitado a 900 px de ancho para que en una pantalla
   grande siga leyendose. La rejilla de fotos cambia de 2 a 4 columnas segun el
   ancho.
3. **Configuracion por `--dart-define-from-file`**, no por codigo: `env/dev.json`
   para local, `env/dev.android.json` para el emulador (donde `localhost` es
   `10.0.2.2`) y `env/prod.example.json` como plantilla del despliegue.
4. **Autenticacion por `Authorization: Bearer`**, igual en las dos plataformas,
   porque en movil no hay cookies (ver ADR 0003 del backend). Cero
   `if (kIsWeb)` en la logica de sesion.
5. **URLs reales en web**: `go_router` con rutas nombradas, de modo que
   `/memories/<id>` sea un enlace que se puede compartir y recargar.

## Consecuencias

- Lo que se prueba en web vale para movil casi siempre; lo que hay que probar en
  ambos es la seleccion de fotos y el almacenamiento seguro.
- En web, `flutter_secure_storage` cae a un almacen del navegador, menos seguro
  que el Keychain. Se asume con tokens de acceso cortos y rotacion del de
  refresco.
- La API tiene que permitir el origen de la web por CORS: esta en
  `CORS_ORIGINS` del backend.
- Al anadir una funcionalidad hay que preguntarse si usa alguna API que no exista
  en web. Si la usa, va detras de una interfaz en `core/`, no de un `if`
  esparcido por las pantallas.
