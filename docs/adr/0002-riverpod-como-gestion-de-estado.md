# ADR 0002 — Riverpod para el estado

- Estado: aceptada
- Fecha: 2026-09-22

## Contexto

Hacen falta tres cosas: estado compartido (la sesion), estado por pantalla (la
lista, el formulario) y poder probar esa logica sin abrir la aplicacion.

Las alternativas razonables eran Bloc y Riverpod.

## Decision

**Riverpod 2**, con `AsyncNotifier` para lo que se carga de la API y `Notifier`
para el estado de formulario.

Motivos:

- No necesita `BuildContext`: la logica se prueba con un `ProviderContainer` en
  un test normal.
- `AsyncValue` ya trae los tres estados (cargando, dato, error) y evita que cada
  pantalla invente su propia forma de mostrarlos: de ahi sale `AsyncView`.
- Sustituir una dependencia en un test es una linea (`overrideWithValue`), que es
  el equivalente a la inyeccion de dependencias del backend.
- Bloc habria funcionado igual de bien, pero pide mas ceremonia (evento, estado,
  bloc) para pantallas que en su mayoria son "cargar y mostrar".

## Consecuencias

- Todos los providers de una feature viven en `presentation/providers/`: es el
  equivalente del `dependencies.py` del backend.
- Un controlador no toca widgets; una pantalla no toca Dio.
- Riverpod tiene generacion de codigo opcional (`riverpod_generator`). **No se
  usa**, ver [ADR 0003](0003-sin-generacion-de-codigo.md).
