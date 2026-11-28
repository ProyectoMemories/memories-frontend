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

Colores tomados del **código** del mockup (las pantallas V4 del lienzo), no
de una captura: son exactos. La primera versión de esta tabla se midió sobre
una imagen y difería unos tonos; se corrigió en F5. Van en `lib/views/theme/`
como `ThemeData` y constantes; ninguna pantalla escribe un color suelto.

| Token | Color | Uso |
|---|---|---|
| `background` | `#F4ECDF` | Fondo de las pantallas |
| `surface` | `#FFFBF4` | Campos, tarjetas, barra inferior, pie con el botón principal |
| `primary` | `#7A2E2A` | Botón principal, enlaces, barra de progreso activa, casilla marcada |
| `primaryPressed` | `#5E2220` | Botón principal y enlaces al pasar el mouse o presionar |
| `onPrimary` | `#FFFBF4` | Texto del botón principal |
| `textPrimary` | `#2B211B` | Títulos y texto de los campos |
| `textSecondary` | `#6B5B4E` | Subtítulos, ayudas, placeholders, ítems inactivos de la barra |
| `label` | `#5A4A3E` | Etiquetas de campo en mayúsculas |
| `border` | `#DCCDB8` | Borde de los campos |
| `divider` | `#E7DAC6` | Líneas entre filas y borde de la barra inferior |
| `iconTile` | `#EADDC9` | Cuadro del ícono (correo, candado), botón de buscar, selector de pestañas |
| `progressTrack` | `#E3D3BC` | Barra de progreso inactiva |
| `toast` | `#2B211B` | Fondo de los avisos ("Correo reenviado") |
| `toastIcon` | `#E2A93B` | Ícono de los avisos |
| `danger` | `#A3261F` | Acciones que borran ("Eliminar cuenta") y mensajes de error |

Medidas del mockup: campos de 52 px de alto con radio 14 y borde de 1,5 px;
botones de 54 px con radio 16; etiquetas de 13 px en peso 800; texto de los
campos de 16 px en peso 600; títulos en Fraunces 700 (38 px en Iniciar sesión,
30 px en Inicio y Perfil, 28 px en avisos de pantalla completa).

Tipografía **[DECIDIDO]** (D79): **Fraunces** para títulos (serif cálida, con
aire de libro, encaja con "guardar el significado") y **Nunito Sans** para el
texto (sans de terminaciones suaves, legible en tamaños chicos). Las dos tienen
licencia OFL y salen de `google/fonts`; se empaquetan en `assets/fonts/` junto a
su `OFL.txt`. `google/fonts` solo las trae variables, y en Flutter el peso de
una fuente variable no sigue a `fontWeight`; por eso se empaquetan versiones
fijas de los pesos del mockup (Fraunces 500, 700 y 500 cursiva; Nunito Sans
400, 600, 700 y 800). Cómo se generan: `assets/fonts/README.md`.

Componentes compartidos (en `lib/views/widgets/`): campo con etiqueta en
mayúsculas y texto de ayuda o error; campo de contraseña con botón para mostrar
u ocultar; botón principal y botón con borde, con estado "cargando"; cuadro de
ícono; barra de progreso de dos pasos; aviso inferior (SnackBar con el estilo
`toast`); cabecera de fotos tipo polaroid de Iniciar sesión.

Un solo diseño adaptativo (CLAUDE.md §7): en pantallas anchas, las pantallas de
auth se centran en una columna de unos 420 px.

## 4. Pantallas, rutas y ViewModels

Rutas en inglés; las dos que abre el correo las fija el backend (D65, D73).
En web van sin `#` (`usePathUrlStrategy`): el enlace del correo llega como
`/verify-email?token=...`.

| Ruta | Pantalla del mockup | ViewModel | Estados |
|---|---|---|---|
| `/login` | Iniciar sesión | `LoginViewModel` | inicial, campo vacío (error en el campo), enviando, error (mensaje), sin verificar → `/check-email` |
| `/register` | Registro 1: datos | `RegisterViewModel` (compartido por los dos pasos) | campo vacío (error en el campo), menor de 14 → `/register/underage` |
| `/register/access` | Registro 2: acceso | `RegisterViewModel` | error por campo antes de enviar, casilla sin marcar, enviando, error de la API por campo, listo → `/check-email` |
| `/register/underage` | Menor de 14 | — (borra lo escrito: "No guardamos los datos") | — |
| `/check-email` | Verifica tu correo | `CheckEmailViewModel` | reenviando, reenviado (aviso), sin correo conocido (pide el correo para reenviar) |
| `/verify-email?token=` | Aprobada con la spec: estilo de "Verifica tu correo": "Correo verificado" o "El enlace venció" | `VerifyEmailViewModel` | verificando, verificado, vencido o usado |
| `/forgot-password` | Recuperar contraseña | `ForgotPasswordViewModel` | enviando, enviado (aviso) |
| `/reset-password?token=` | Nueva contraseña | `ResetPasswordViewModel` | enviando, no coinciden, enlace vencido, listo → `/login` con aviso |
| `/home` | Inicio: álbumes (sin álbumes) | — | — |
| `/profile` | Perfil (solo "Cambiar contraseña" y "Cerrar sesión") | `ProfileViewModel` | cerrando sesión |
| `/profile/password` | Aprobada con la spec: estilo de "Nueva contraseña" más "Contraseña actual" | `ChangePasswordViewModel` | enviando, actual incorrecta, listo → `/login` con aviso |

`SessionNotifier` (estado de la app: comprobando, con sesión, sin sesión) decide
las redirecciones de `go_router`: sin sesión solo se ven las rutas de auth; con
sesión, las de auth llevan a `/home`, salvo `/reset-password` (§7, F7).

Registro:

- `/register/access` y `/register/underage` son subrutas de `/register`: así
  la flecha atrás del paso 2 vuelve al paso 1 con lo escrito (HU-02) y los dos
  pasos comparten el mismo `RegisterViewModel`. Si se abre `/register/access`
  sin el paso 1 (recarga en web), vuelve a `/register`.
- La app revisa antes de enviar lo mismo que la API (RN-08, RN-10, D40,
  D62-B), para marcar el campo sin esperar. La API igual lo vuelve a revisar.
- La fecha de nacimiento se elige con el calendario de Material en español:
  `flutter_localizations` (del SDK de Flutter, sin versión aparte) traduce los
  textos de Material de toda la app.
- El correo llega a `/check-email` por `extra` de `go_router`, no en la URL:
  no va al servidor ni aparece en la barra de direcciones. En web, go_router
  lo guarda en el historial de esa pestaña, así que sobrevive a una recarga.
  Si no llega (login con nombre de usuario, o `/check-email` abierto
  directamente), la pantalla pide el correo para reenviar.
- La edad se calcula con la fecha del dispositivo; la API usa la suya. El día
  que alguien cumple 14 puede haber unas horas de diferencia por la zona
  horaria: la app puede hacer esperar hasta un día más que la API (aceptado).
- Botón atrás de Android: las pantallas de auth se abren con `go`, así que
  cada una hace lo mismo que su flecha (Registro → login, paso 2 → paso 1,
  Revisa tu correo y `/verify-email` → login). Mientras se crea la cuenta, ni
  la flecha ni el botón atrás responden: el resultado se perdería.

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
| (campo vacío, sin llamar a la API) | — | Login | En el campo: "Escribe tu correo o nombre de usuario." / "Escribe tu contraseña." |
| `invalid_credentials` | 401 | Login | "El usuario o la contraseña no son correctos." |
| `email_not_verified` | 403 | Login | Va a "Revisa tu correo" (F6). En F5, que todavía no tiene esa pantalla: "Tu cuenta todavía no está verificada. Revisa tu correo para activarla." |
| `account_suspended` | 403 | Login | "Esta cuenta está suspendida." |
| `too_many_requests` | 429 | Todas | "Demasiados intentos. Prueba en N segundos." (`Retry-After`). En Iniciar sesión N baja cada segundo y el aviso desaparece en cero (el lector de pantalla lo anuncia una sola vez); en las demás pantallas el número queda fijo |
| `username_taken` / `email_taken` | 409 | Registro 2 | En el campo: "Ese nombre de usuario ya existe." / "Ese correo ya tiene una cuenta." |
| `password_length` / `password_too_common` | 422 | Registro 2, contraseñas | En el campo: "Usa de 8 a 64 caracteres." / "Es una contraseña muy común; elige otra." |
| `underage` | 422 | Registro | Va a "Menor de 14" |
| `privacy_policy_not_accepted` | 422 | Registro 2 | No debería llegar (el botón exige la casilla) |
| `expired_token` / `invalid_token` | 400 | `/verify-email`, `/reset-password` | "El enlace venció o ya se usó. Pide uno nuevo." |
| `current_password_incorrect` | 422 | Cambiar contraseña | En el campo: "La contraseña actual no es correcta." |
| `invalid_refresh_token`, `not_authenticated` | 401 | Interceptor | Sin mensaje: vuelve a Iniciar sesión |
| `origin_not_allowed` | 403 | Interceptor (web) | Error de configuración: la app web debe correr en el puerto 3000 |
| Sin conexión o 5xx | — | Todas | "No pudimos conectar. Revisa tu conexión e inténtalo de nuevo." |
| Otro `code` (no previsto) | — | Todas | "Algo salió mal. Inténtalo de nuevo." |

## 7. Riesgos

- **Errores de los campos y lector de pantalla:** al pulsar el botón con
  campos mal, la app anuncia "Revisa los campos marcados."; cada campo lee su
  error al recibir el foco.
- **Campos de contraseña sin dibujar en el mockup** ("Registro 2" y "Nueva
  contraseña" muestran un bloque gris): se usan los mismos campos con botón de
  mostrar u ocultar (aprobado con la spec).
- **Sin endpoint para leer el perfil:** resuelto. `GET /users/me` llegó con
  el módulo `users`; la cabecera de Perfil y el nombre del saludo están en
  `specs/users`.
- **Tipografía sin confirmar** (§3): si cambia, solo se toca el tema.
- **Rutas web sin `#`:** al desplegar, el servidor tendrá que devolver
  `index.html` en cualquier ruta (por ejemplo `/verify-email`). Se resuelve con
  la decisión de despliegue, que sigue **[PENDIENTE]**.
- **Enlaces del correo con sesión abierta** (decidido por el equipo el
  2026-11-27; falta registrarlo en el 01):
  - `/verify-email` se abre con o sin sesión y verifica sin cerrar la sesión
    abierta, aunque el enlace sea de otra cuenta (el token prueba que quien lo
    abre recibió ese correo). Con sesión, el botón es "Ir a Inicio". Así el
    enlace nunca se pierde: ni el de la misma cuenta ni el de otra cuenta en
    el mismo navegador. Verificar dos veces no cambia nada en la API.
  - `/reset-password` con sesión se abre igual (F7): primero cierra la sesión
    actual y luego muestra el formulario, para que el enlace no se pierda.
- **Fecha de nacimiento que no se cambia** (**[PROPUESTA]** de RN para el
  05, la decide el equipo): después del registro la persona no puede cambiar
  su fecha de nacimiento (una corrección por soporte queda fuera del MVP;
  RN-02 no le da eso al superusuario). Si se pudiera cambiar,
  bastaría con mentir para saltarse la edad mínima (RN-08). El registro ya lo
  avisa bajo la fecha; quien lo hace cumplir es la API, cuando llegue el
  módulo `users` (hoy no hay forma de cambiarla).
- **Política de privacidad sin página:** la casilla del registro no enlaza a
  la política ni muestra su versión hasta que exista el texto.
  **[PENDIENTE]**.
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
