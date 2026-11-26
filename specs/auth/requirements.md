# Auth en la app — requisitos

Estado: aprobada (2026-11-26, D79)

- Fuente: Lista de requisitos (RF-01, RF-03, RF-04, RF-05, RF-23, RF-24),
  05-reglas-de-negocio (RN-08, RN-10, RN-19, RN-50, RN-67), 01-decisiones
  (D22, D40, D51, D56, D57, D60, D62, D65, D70, D73, D74, D77, D78, D79).
- Mockup: "Memories — Mockup v3", página "Recuerdos 4.0 Movil" (D50), flujo
  "7 · Cuenta" y pantalla "Inicio: álbumes".
- Backend: `memories-backend/specs/auth` (ya en `main`). Contrato en
  `/openapi.json` de la API local.
- Alcance (D78): todo lo que el backend de auth ya ofrece, probado de punta a
  punta en Chrome y en el emulador de Android antes de empezar `users`.

## HU-01 · Iniciar sesión (RF-01) · pantalla "Iniciar sesión"

Como persona con cuenta, quiero entrar con mi correo o nombre de usuario y mi
contraseña para ver mis álbumes.

- **Dado** una cuenta activa, **cuando** escribo correo o usuario y contraseña
  correctos y pulso "Entrar", **entonces** llego a Inicio.
- **Dado** datos incorrectos, **cuando** pulso "Entrar", **entonces** veo un
  error genérico que no dice si el usuario existe (D62-E).
- **Dado** una cuenta sin verificar y la contraseña correcta, **cuando** pulso
  "Entrar", **entonces** voy a "Revisa tu correo" con la opción de reenviarlo
  (D62-E).
- **Dado** una cuenta suspendida, **cuando** entro, **entonces** veo que la
  cuenta está suspendida, sin más detalle.
- **Dado** 6 intentos en un minuto, **cuando** pulso "Entrar", **entonces** veo
  cuántos segundos esperar (`Retry-After`, D70, D77).
- **Dado** que pulso "Entrar", **cuando** espera la respuesta, **entonces** el
  botón muestra que está cargando y no acepta otro toque.

## HU-02 · Crear cuenta en dos pasos (RF-04, RF-24, RF-23) · "Registro 1: datos" y "Registro 2: acceso"

Como persona nueva, quiero crear mi cuenta en dos pasos cortos.

- **Paso 1:** nombre, apellido paterno, apellido materno (opcional) y fecha de
  nacimiento. "Siguiente" se activa con los obligatorios llenos.
- **Dado** una fecha de nacimiento de alguien menor de 14 años, **cuando**
  pulso "Siguiente", **entonces** voy a "Todavía no puedes crear una cuenta"
  y no se envía nada a la API (RN-08). La API igual rechaza con `underage`.
- **Paso 2:** nombre de usuario (regla de RN-10, D40, revisada antes de enviar),
  correo, contraseña de 8 a 64 caracteres (D62-B) y la casilla de la política de
  privacidad (RN-50, D65). "Crear cuenta" se activa solo con la casilla marcada.
- **Dado** datos válidos, **cuando** pulso "Crear cuenta", **entonces** voy a
  "Revisa tu correo" con mi correo escrito.
- **Dado** un usuario o correo ya usados, **cuando** pulso "Crear cuenta",
  **entonces** veo el error junto a ese campo (`username_taken`,
  `email_taken`).
- **Dado** una contraseña común, **cuando** pulso "Crear cuenta",
  **entonces** veo que elija otra (`password_too_common`).
- **Dado** el paso 2, **cuando** vuelvo atrás, **entonces** lo escrito en el
  paso 1 sigue ahí.

## HU-03 · Verificar el correo (RF-23) · "Verifica tu correo" y "Confirmación: correo reenviado"

- **Dado** que acabo de registrarme, **cuando** veo "Revisa tu correo",
  **entonces** dice a qué correo llegó el enlace y que vence en 24 horas.
- **Dado** esa pantalla, **cuando** pulso "Reenviar correo", **entonces** veo
  el aviso "Correo reenviado" (D74: la respuesta es la misma exista o no la
  cuenta).
- **Dado** esa pantalla, **cuando** pulso "Ya lo verifiqué", **entonces** voy a
  Iniciar sesión.
- **Dado** que abro el enlace del correo en el navegador (`/verify-email?token=`,
  D65), **cuando** carga, **entonces** la app web verifica la cuenta y me ofrece
  iniciar sesión. Con el enlace vencido o usado, me ofrece pedir otro.
- En Android, el enlace se abre en el navegador (app web). Abrir la app
  directo desde el correo queda **[PENDIENTE]** (D65).

## HU-04 · Recuperar la contraseña (RF-05, RN-19, D73) · "Recuperar contraseña", "Confirmación: enlace enviado", "Nueva contraseña", "Confirmación: contraseña cambiada"

- **Dado** Iniciar sesión, **cuando** pulso "¿Olvidaste tu contraseña?",
  **entonces** voy a "Recupera tu contraseña".
- **Dado** un correo, **cuando** pulso "Enviar enlace", **entonces** veo "Te
  enviamos el enlace", exista o no la cuenta (D73, D74).
- **Dado** que abro el enlace del correo (`/reset-password?token=`, D73),
  **cuando** escribo la contraseña nueva dos veces iguales y pulso "Guardar
  contraseña", **entonces** vuelvo a Iniciar sesión con el aviso "Contraseña
  cambiada. Inicia sesión."
- **Dado** dos contraseñas distintas, **cuando** pulso "Guardar contraseña",
  **entonces** la app lo marca antes de enviar.
- **Dado** un enlace vencido o ya usado, **cuando** guardo, **entonces** veo que
  pida otro enlace (`expired_token`, `invalid_token`).

## HU-05 · Cambiar la contraseña con sesión iniciada (D73) · entrada "Cambiar contraseña" en "Perfil"

- **Dado** Perfil, **cuando** pulso "Cambiar contraseña", **entonces** veo la
  contraseña actual, la nueva y su repetición. (Aprobado con la spec.) El mockup tiene
  la entrada pero no la pantalla: se arma con el estilo de "Nueva contraseña".
- **Dado** la contraseña actual incorrecta, **cuando** guardo, **entonces** veo
  el error en ese campo (`current_password_incorrect`, 422, D73).
- **Dado** el cambio correcto, **cuando** termina, **entonces** se cierran todas
  las sesiones, también la mía (D73), y vuelvo a Iniciar sesión con el aviso
  "Contraseña cambiada. Inicia sesión."

## HU-06 · Seguir conectado y cerrar sesión (D56, RN-67)

- **Dado** que inicié sesión, **cuando** cierro y vuelvo a abrir la app,
  **entonces** sigo dentro sin escribir la contraseña (hasta 30 días).
- **Dado** que el token de acceso venció (15 min), **cuando** la app pide algo a
  la API, **entonces** lo renueva sola y la persona no nota nada.
- **Dado** dos peticiones que fallan a la vez por token vencido, **cuando** se
  renueva, **entonces** se hace una sola renovación (si no, la API lo toma como
  reuso y cierra la sesión).
- **Dado** que la renovación falla (sesión revocada o vencida), **cuando**
  ocurre, **entonces** vuelvo a Iniciar sesión.
- **Dado** Perfil, **cuando** pulso "Cerrar sesión", **entonces** la API revoca
  esa sesión, se borran los tokens del dispositivo y vuelvo a Iniciar sesión.

## HU-07 · Inicio y Perfil provisionales

- **Dado** que inicié sesión, **cuando** llego a Inicio, **entonces** veo la
  estructura de "Inicio: álbumes" (saludo, título, barra inferior con Inicio,
  Álbum y Perfil) sin álbumes. Los álbumes llegan con su módulo (D78).
- **Dado** Perfil, **cuando** lo abro, **entonces** veo "Cambiar contraseña" y
  "Cerrar sesión". Nombre, usuario y correo de la cabecera llegan con el módulo
  `users`, porque la API todavía no tiene un endpoint para leerlos.

## Fuera de esta spec

Editar perfil, desactivar y eliminar cuenta (llegan con `users`), administración
y superusuario, álbumes y recuerdos, abrir la app de Android desde el correo.
