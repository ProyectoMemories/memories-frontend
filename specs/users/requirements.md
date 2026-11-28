# Users en la app — requisitos

Estado: **aprobada** (2026-11-28)

- Fuente: Lista de requisitos (RF-04, RNF-02), 01-decisiones (D50, D57, D78,
  D79; por registrar: D81 "users es dueño del perfil" y D82 "el nombre va
  antes de F7").
- Mockup: "Memories — Mockup v3", página "Recuerdos 4.0 Movil" (D50),
  pantallas "Perfil" e "Inicio: álbumes".
- Backend: `memories-backend/specs/users` (ya en `main`, PR #27):
  `GET /api/v1/users/me`.
- Alcance de esta entrega: **solo mostrar** quién inició sesión. Editar el
  perfil, desactivar y eliminar la cuenta llegan después, en esta misma spec.

## HU-01 · Saber con qué cuenta entré (RF-04)

Como persona con sesión iniciada, quiero ver mi nombre en la app para saber
con qué cuenta entré.

- **Dado** que inicié sesión, **cuando** llego a Inicio, **entonces** el
  saludo dice mi nombre: "Buenas noches, Victor" (según la hora, como hoy).
- **Dado** Perfil, **cuando** lo abro, **entonces** veo arriba una tarjeta con
  mis iniciales, mi nombre y apellido paterno, mi usuario con `@` y mi correo.
- **Dado** que mis datos todavía no llegan, **cuando** veo Inicio, **entonces**
  el saludo dice solo "Buenas noches", sin texto de relleno; en Perfil, la
  tarjeta muestra que está cargando.
- **Dado** que no se pudieron cargar mis datos (sin conexión o error de la
  API), **cuando** veo Inicio, **entonces** el saludo queda sin nombre y no se
  muestra ningún error (el saludo no es crítico); en Perfil, la tarjeta dice
  "No pudimos cargar tus datos." con un botón "Reintentar".
- **Dado** que cierro sesión y entro con otra cuenta, **cuando** veo Inicio o
  Perfil, **entonces** aparecen los datos de la cuenta nueva, nunca los de la
  anterior (RNF-02).
- **Dado** que mi sesión venció o se cerró en otro lado, **cuando** la app pide
  mis datos, **entonces** vuelvo a Iniciar sesión, como en el resto de la app.
- **Dado** un lector de pantalla, **cuando** llega a la tarjeta de Perfil,
  **entonces** lee el nombre, el usuario y el correo, sin leer las iniciales
  del avatar.

## Fuera de esta entrega

Editar perfil (con la fecha de nacimiento fija, regla por registrar en el 05),
desactivar y eliminar la cuenta, "Administración" del superusuario y la foto de
perfil (el mockup solo muestra iniciales).
