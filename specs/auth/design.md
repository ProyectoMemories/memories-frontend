# Auth en la app — diseño

Cómo se construye lo de `requirements.md`. Fase: UX/UI y Arquitectura. MVVM con
Riverpod (D13, D57) y la estructura del CLAUDE.md §5.

## 1. Pasos (D78)

| Paso | Rama | Qué entrega | Se prueba |
|---|---|---|---|
| F3 | `feat/api-client` | Cliente generado desde el OpenAPI del backend | Compila; un test llama al cliente con un doble de dio |
| F4 | `feat/auth-session` | Repositorio de auth, tokens guardados y renovación sola | ViewModels y repositorio con dobles, incluido "dos 401 a la vez = una renovación" |
| F5 | `feat/auth-login` | Tema del mockup, navegación, Iniciar sesión, Inicio y Perfil provisionales, cerrar sesión | Widget test del login; contra el backend local en Chrome y el emulador. **Cierra P20** |
| F6 | `feat/auth-register` | Registro en dos pasos, menor de 14, Revisa tu correo, reenviar, `/verify-email` | Widget tests; registro real con el correo en Mailpit |
| F7 | `feat/auth-password` | Recuperar, `/reset-password`, cambiar contraseña | Widget tests; recuperación real con Mailpit |

Al cerrar F7: `integration_test` del recorrido completo (registro → verificación
→ login → cambiar contraseña → logout) contra el Docker del backend.

## 2. Decisiones de este diseño ([DECIDIDO], D79)

| # | Decisión | Por qué |
|---|---|---|
| 1 | Cliente generado en un paquete local `packages/memories_api` (carpeta de primer nivel nueva), guardado en el repo y regenerado a mano cuando cambia la API | El CI no necesita Java ni el backend para compilar; el diff del PR muestra qué cambió en el contrato |
| 2 | `go_router` para la navegación | La web necesita URLs reales: `/verify-email?token=` (D65) y `/reset-password?token=` (D73) |
| 3 | `flutter_secure_storage` para los tokens en Android | D56: almacenamiento seguro del sistema (Keystore). En web no se usa: el token de renovación va en la cookie `HttpOnly` y el de acceso solo en memoria (CLAUDE.md §8) |
| 4 | Fuentes del mockup empaquetadas en `assets/fonts/` (carpeta de primer nivel nueva), sin descargarlas en tiempo de ejecución | Funciona sin red y no manda peticiones a terceros (privacidad por defecto) |

Versiones: exactas, mantenidas y publicadas hace al menos dos semanas; se fijan
en la tarea que las agrega. openapi-generator con la imagen Docker
`openapitools/openapi-generator-cli` en una versión fijada (sin instalar Java).

## 3. Tema del mockup ("Recuerdos 4.0 Movil")

Colores medidos sobre el mockup (pueden diferir unos tonos por la compresión).
Van en `lib/views/theme/` como `ThemeData` y constantes; ninguna pantalla
escribe un color suelto.

| Token | Color | Uso |
|---|---|---|
| `background` | `#F4ECDF` | Fondo de las pantallas |
| `surface` | `#FFFAF4` | Campos, tarjetas, pie con el botón principal |
| `primary` | `#7A2E29` | Botón principal, enlaces, barra de progreso activa, casilla marcada |
| `onPrimary` | `#FFFFFF` | Texto del botón principal |
| `textPrimary` | `#1F1712` | Títulos y texto de los campos |
| `textSecondary` | `#6B6156` | Subtítulos, ayudas y placeholders |
| `label` | `#3B2D2D` | Etiquetas de campo en mayúsculas |
| `border` | `#E7DFD4` | Borde de los campos |
| `iconTile` | `#EADDCA` | Cuadro del ícono (correo, candado) |
| `progressTrack` | `#DED2BC` | Barra de progreso inactiva |
| `toast` | `#2A211C` | Fondo de los avisos ("Correo reenviado") |

Tipografía **[DECIDIDO]** (D79): **Fraunces** para títulos (serif cálida, con
aire de libro, encaja con "guardar el significado") y **Nunito Sans** para el
texto (sans de terminaciones suaves, legible en tamaños chicos). Las dos tienen
licencia OFL y salen de `google/fonts`; se empaquetan en `assets/fonts/` junto a
su `OFL.txt`.

Componentes compartidos (en `lib/views/widgets/`): campo con etiqueta en
mayúsculas y texto de ayuda o error; campo de contraseña con botón para mostrar
u ocultar; botón principal y botón con borde, con estado "cargando"; cuadro de
ícono; barra de progreso de dos pasos; aviso inferior (SnackBar con el estilo
`toast`); cabecera de fotos tipo polaroid de Iniciar sesión.

Un solo diseño adaptativo (CLAUDE.md §7): en pantallas anchas, las pantallas de
auth se centran en una columna de unos 420 px.

## 4. Pantallas, rutas y ViewModels

Rutas en inglés; las dos que abre el correo las fija el backend (D65, D73).

| Ruta | Pantalla del mockup | ViewModel | Estados |
|---|---|---|---|
| `/login` | Iniciar sesión | `LoginViewModel` | inicial, enviando, error (mensaje), sin verificar → `/check-email` |
| `/register` | Registro 1: datos | `RegisterViewModel` (compartido por los dos pasos) | completo / incompleto, menor de 14 → `/register/underage` |
| `/register/access` | Registro 2: acceso | `RegisterViewModel` | enviando, error por campo, listo → `/check-email` |
| `/register/underage` | Menor de 14 | — | — |
| `/check-email` | Verifica tu correo | `CheckEmailViewModel` | reenviando, reenviado (aviso) |
| `/verify-email?token=` | Aprobada con la spec: estilo de "Verifica tu correo": "Correo verificado" o "El enlace venció" | `VerifyEmailViewModel` | verificando, verificado, vencido o usado |
| `/forgot-password` | Recuperar contraseña | `ForgotPasswordViewModel` | enviando, enviado (aviso) |
| `/reset-password?token=` | Nueva contraseña | `ResetPasswordViewModel` | enviando, no coinciden, enlace vencido, listo → `/login` con aviso |
| `/home` | Inicio: álbumes (sin álbumes) | — | — |
| `/profile` | Perfil (solo "Cambiar contraseña" y "Cerrar sesión") | `ProfileViewModel` | cerrando sesión |
| `/profile/password` | Aprobada con la spec: estilo de "Nueva contraseña" más "Contraseña actual" | `ChangePasswordViewModel` | enviando, actual incorrecta, listo → `/login` con aviso |

`SessionNotifier` (estado de la app: comprobando, con sesión, sin sesión) decide
las redirecciones de `go_router`: sin sesión solo se ven las rutas de auth; con
sesión, las de auth llevan a `/home`.

## 5. Datos y sesión

- `lib/repositories/auth_repository.dart`: único que usa el cliente generado
  para auth. Devuelve tipos propios (resultado o error con su `code`), nunca
  tipos de dio ni modelos generados (CLAUDE.md §7).
- Tokens (`lib/repositories/session/`):
  - Android: los dos tokens en `flutter_secure_storage`.
  - Web: el de acceso solo en memoria; el de renovación lo maneja el navegador
    en la cookie `memories_refresh`. dio va con `withCredentials: true` en el
    `extra` de sus opciones base, que el adaptador web lee en cada petición
    (sin eso el navegador no guarda ni envía la cookie). Así se prueba sin
    importar el adaptador del navegador en los tests.
  - `platform` en login: `android` o `web` según `kIsWeb`, sin `dart:io` en
    código compartido.
- Interceptor de dio: con `access_token_expired` renueva y repite la petición.
  Si la renovación falla, la petición falla con el error de la renovación:
  `invalid_refresh_token` si la sesión ya no vale, `network` sin conexión o
  con un 5xx.
- **Renovaciones de una en una** (`RefreshGate`, compartido): el interceptor,
  la recuperación de la sesión al abrir la app y el cierre de sesión pasan por
  la misma pieza. Si hay una renovación en curso, las demás esperan su
  resultado, y cerrar sesión espera a que termine para mandar el token ya
  rotado. Si una petición falló con el token viejo y otra ya renovó, se repite
  con el nuevo sin renovar otra vez.
- **Cuándo se cierra la sesión sola** (se borran los tokens y `SessionNotifier`
  pasa a "sin sesión"): si la renovación responde `invalid_refresh_token`, o si
  una petición que llevaba token responde `not_authenticated` (sesión revocada
  desde otro dispositivo o cuenta desactivada con el token aún vigente, D56).
  Sin conexión o con un 5xx la sesión se mantiene: perder la señal no cierra
  la sesión (HU-06).
- **Web sin conexión al abrir:** no hay token de acceso (vive en memoria), así
  que la app queda en "sin sesión" y pide iniciar sesión. La sesión de la
  cookie sigue abierta en el servidor hasta que vence o se usa.
- El token de acceso solo se manda a los endpoints que el OpenAPI marca con
  seguridad `HTTPBearer` (el cliente generado lo indica en `extra['secure']`).
  Una petición que ya se repitió no vuelve a renovar: si otra vez llega
  `access_token_expired`, falla.
- Un fallo inesperado (que no viene de la API) al renovar o al recuperar la
  sesión se reporta con `FlutterError.reportError`, nunca deja peticiones
  esperando y, al abrir la app, deja la sesión en "sin sesión".
- Android en depuración: la API local va por `http://10.0.2.2:8001`, así que se
  permite tráfico sin cifrar **solo** en `debug` (configuración de red de
  depuración), nunca en `release`.

## 6. Errores de la API → mensajes (con `design:ux-copy`)

| `code` | HTTP | Dónde | Mensaje |
|---|---|---|---|
| `invalid_credentials` | 401 | Login | "El usuario o la contraseña no son correctos." |
| `email_not_verified` | 403 | Login | Va a "Revisa tu correo" |
| `account_suspended` | 403 | Login | "Esta cuenta está suspendida." |
| `too_many_requests` | 429 | Todas | "Demasiados intentos. Prueba en N segundos." (`Retry-After`) |
| `username_taken` / `email_taken` | 409 | Registro 2 | En el campo: "Ese nombre de usuario ya existe." / "Ese correo ya tiene una cuenta." |
| `password_length` / `password_too_common` | 422 | Registro 2, contraseñas | En el campo: "Usa de 8 a 64 caracteres." / "Es una contraseña muy común; elige otra." |
| `underage` | 422 | Registro | Va a "Menor de 14" |
| `privacy_policy_not_accepted` | 422 | Registro 2 | No debería llegar (el botón exige la casilla) |
| `expired_token` / `invalid_token` | 400 | `/verify-email`, `/reset-password` | "El enlace venció o ya se usó. Pide uno nuevo." |
| `current_password_incorrect` | 422 | Cambiar contraseña | En el campo: "La contraseña actual no es correcta." |
| `invalid_refresh_token`, `not_authenticated` | 401 | Interceptor | Sin mensaje: vuelve a Iniciar sesión |
| `origin_not_allowed` | 403 | Interceptor (web) | Error de configuración: la app web debe correr en el puerto 3000 |
| Sin conexión o 5xx | — | Todas | "No pudimos conectar. Revisa tu conexión e inténtalo de nuevo." |

## 7. Riesgos

- **Campos de contraseña sin dibujar en el mockup** ("Registro 2" y "Nueva
  contraseña" muestran un bloque gris): se usan los mismos campos con botón de
  mostrar u ocultar (aprobado con la spec).
- **Sin endpoint para leer el perfil:** la cabecera de Perfil y el nombre del
  saludo de Inicio esperan al módulo `users` (D78).
- **Tipografía sin confirmar** (§3): si cambia, solo se toca el tema.
- **Puerto 3000 en web:** con otro puerto, CORS bloquea y `/refresh` responde
  `origin_not_allowed`.
- **Renovaciones simultáneas:** un error en el interceptor cierra la sesión del
  usuario. Todo el que usa el token de renovación pasa por `RefreshGate`, y hay
  tests (con prueba de mutación) de dos 401 a la vez, de una 401 que llega
  después de otra renovación y de cerrar sesión durante una renovación.
- **Renovación que empieza mientras viaja el `logout`** (aceptado): cerrar
  sesión espera la renovación en curso, pero no impide que empiece otra si
  justo entonces una petición recibe `access_token_expired`. En el servidor la
  sesión queda revocada igual (por logout o por reuso); en el dispositivo la
  respuesta tardía podría volver a guardar tokens de una sesión ya revocada, y
  la primera petición con ellos cierra la sesión (`invalid_refresh_token` o
  `not_authenticated`). Si se ve en la práctica, `logout` toma el
  `RefreshGate` en exclusiva.

## 8. Pruebas (con `engineering:testing-strategy`)

- ViewModels: `ProviderContainer` con un doble de `AuthRepository`, sin servidor.
- Repositorio e interceptor: dio con un adaptador falso; caso de dos 401 a la vez.
- Widget tests: login, registro (dos pasos y menor de 14), nueva contraseña.
- `integration_test` del recorrido completo contra el backend local, en Chrome
  (puerto 3000) y en el emulador.
