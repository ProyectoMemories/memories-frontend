# Spec: entrar en la app — Requisitos

- Capacidad del PRD: soporte de CP-06 (privacidad por defecto)
- Contrato de la API: `specs/auth/` del repositorio `memories-backend`
- Estado: implementado

## Historias de usuario

### HU-01 — Crear cuenta y entrar

> Como persona nueva, quiero crear mi cuenta desde la app, para empezar a
> guardar recuerdos sin pasos intermedios.

- Dados un nombre, un correo y una contrasena validos, cuando creo la cuenta,
  entonces entro directamente: no se me pide iniciar sesion otra vez.
- Dado un correo que ya existe, cuando creo la cuenta, entonces veo el mensaje
  que devuelve la API y sigo en la pantalla.
- Dada una contrasena de menos de 8 caracteres, cuando envio el formulario,
  entonces se marca el campo **antes** de llamar a la API.

### HU-02 — Iniciar sesion

- Dadas credenciales correctas, cuando entro, entonces veo mis recuerdos.
- Dadas credenciales incorrectas, cuando entro, entonces veo un aviso y sigo en
  la pantalla, con lo escrito intacto.
- Mientras la peticion esta en curso, el boton muestra progreso y no admite un
  segundo toque.

### HU-03 — Seguir dentro entre sesiones

> Como persona que usa la app a diario, quiero no tener que escribir la
> contrasena cada vez que la abro.

- Dada una sesion guardada, cuando abro la app, entonces entro directamente.
- Mientras se comprueba, veo una pantalla de carga, no el formulario de inicio
  de sesion (que desapareceria al instante).
- Dado un token de acceso vencido, cuando hago cualquier accion, entonces la
  sesion se renueva sola y la accion se completa sin que yo note nada.
- Dada una sesion que ya no vale, cuando la renovacion falla, entonces vuelvo al
  inicio de sesion sin errores raros por el camino.

### HU-04 — Ver mi perfil y salir

- Dado que estoy dentro, cuando abro el perfil, entonces veo mi nombre, mi correo
  y mi rol.
- Dado que cierro sesion, entonces vuelvo al inicio de sesion y mis tokens
  desaparecen del dispositivo.

## Fuera de esta feature

Recuperar la contrasena, verificar el correo, entrar con Google o Apple, y editar
la foto de perfil (no hay fotos de perfil).
