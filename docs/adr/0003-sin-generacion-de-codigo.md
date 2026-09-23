# ADR 0003 — Sin generacion de codigo (por ahora)

- Estado: aceptada
- Fecha: 2026-09-22

## Contexto

Lo habitual en Flutter es `freezed` + `json_serializable` + `riverpod_generator`,
todo sobre `build_runner`. Ahorran escribir `fromJson`, `copyWith` y providers.

## Decision

En el esqueleto **no** se usa generacion de codigo:

- Los DTOs traducen el JSON a mano (`MemoryDto`, `UserDto`).
- Los providers se declaran a mano.
- `copyWith` se escribe donde hace falta (es un solo sitio: el formulario).

Motivos:

1. **El proyecto arranca recien clonado.** `flutter pub get && flutter run`
   funciona sin pasar antes por `dart run build_runner build`, que es donde suele
   atascarse quien entra nuevo al proyecto.
2. Son cuatro objetos de datos. El ahorro de codigo generado no compensa todavia
   una herramienta mas en el CI y en cada maquina.
3. Los errores de traduccion salen en el sitio donde estan, no dentro de un
   archivo generado.

## Consecuencias

- Al anadir un campo a un recuerdo hay que tocar el DTO a mano. Si se olvida, el
  test de traduccion (`test/features/memories/memory_dto_test.dart`) lo detecta.
- **Cuando esto deje de compensar** —mas o menos a partir de diez objetos de
  datos, o cuando haya uniones de estados— se adopta `freezed` y se revisa este
  ADR. La estructura no cambia: solo la forma de escribir los DTOs.
