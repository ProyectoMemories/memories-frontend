# Users en la app — diseño

Cómo se construye lo de `requirements.md`. Fase: UX/UI y Arquitectura. MVVM con
Riverpod (D13, D57) y la estructura del CLAUDE.md §5. Usa el tema de
`specs/auth/design.md` §3.

## 1. Pasos

| Paso | Rama | Qué entrega | Se prueba |
|---|---|---|---|
| U1 | `feat/profile-name` | Cliente regenerado, repositorio, nombre en Inicio y tarjeta de Perfil | Tests del repositorio, del ViewModel y widget tests; contra el backend local en Chrome y el emulador |

Sin dependencias nuevas.

## 2. Datos

- **Repositorio** `lib/repositories/users_repository.dart`: `UsersRepository`
  con `Future<Profile> myProfile()`, que llama a `GET /api/v1/users/me` con el
  `UsersApi` generado. El token lo pone `SessionInterceptor`, que ya renueva
  solo y avisa si la sesión terminó (design de auth §5). Los errores pasan por
  `ApiError`, como en `AuthRepository`.
- **`Profile`** (en el mismo archivo, como `Registration` en auth): `firstName`,
  `paternalSurname`, `maternalSurname`, `username`, `email`. Las vistas y los
  ViewModels nunca ven `ProfileResponse` (CLAUDE.md §7).
  - `displayName`: nombre y apellido paterno ("Victor Vergara"), como el
    mockup.
  - `initials`: primera letra del nombre y del apellido paterno, en mayúsculas
    ("VV").

## 3. ViewModel

`lib/view_models/users/my_profile_view_model.dart`:

- `myProfileProvider`: `AsyncNotifierProvider<MyProfileViewModel, Profile?>`,
  compartido por Inicio y Perfil (una sola petición para las dos pantallas).
- **Mira `sessionProvider`**: si no hay sesión, vale `null` sin pedir nada; al
  pasar a "con sesión", pide el perfil de nuevo. Así, al cerrar sesión y
  entrar con otra cuenta, nunca quedan los datos de la anterior (RNF-02).
- Sin reintentos automáticos (`retry: null`, como en auth): el reintento es el
  botón de Perfil, que llama a `retry()` (`ref.invalidateSelf()`).
- No usa `autoDispose`: al ir de Inicio a Perfil no se vuelve a pedir.

## 4. Pantallas (mockup "Recuerdos 4.0 Movil")

**Inicio** (`lib/views/home_view.dart`): el saludo pasa a
`"$saludo, $nombre"` con el `firstName`. Mientras carga o si falla, solo
`"$saludo"`. Misma letra que hoy (14 px, 700, `textSecondary`).

**Perfil** (`lib/views/auth/profile_view.dart`, sin moverla: también tiene
"Cerrar sesión", que es de auth): entre el título y la tarjeta de "Cerrar
sesión" va la tarjeta nueva `ProfileHeader`
(`lib/views/users/profile_header.dart`):

| Elemento | Mockup |
|---|---|
| Tarjeta | `surface`, radio 16, sombra suave, padding 14, separación 14 |
| Avatar | círculo de 60 px, fondo `#A0785A` (segundo color de las fotos), iniciales en Nunito Sans 800, 20 px, `onPrimary` |
| Nombre | Fraunces 700, 19 px, `textPrimary` |
| Usuario y correo | `@usuario · correo`, Nunito Sans 700, 13 px, `textSecondary` |

- Textos largos: el nombre se corta con "…" en una línea; usuario y correo
  pueden ocupar dos líneas y luego se cortan con "…".
- **Cargando:** la misma tarjeta con el avatar y dos barras en `iconTile`, sin
  animación, y semántica "Cargando tus datos".
- **Error:** la tarjeta con "No pudimos cargar tus datos." y un botón de texto
  "Reintentar" (mínimo 44 px de alto).
- **Accesibilidad:** el avatar se excluye de la semántica; la tarjeta se lee
  como un solo bloque: "Victor Vergara, @victor.vergara, victor@correo.com".

## 5. Errores

| Caso | Qué pasa |
|---|---|
| 401 (sesión vencida o cerrada) | El interceptor intenta renovar; si no puede, vuelve a Iniciar sesión (sin mensaje) |
| Sin conexión o 5xx | Inicio: saludo sin nombre. Perfil: "No pudimos cargar tus datos." + "Reintentar" |

## 6. Pruebas (con `engineering:testing-strategy`)

- Repositorio con un doble de dio: traduce `ProfileResponse` a `Profile`
  (también `maternal_surname` nulo) y un error de red a `ApiError`.
- `Profile`: `displayName` e `initials`, incluidos nombres con tilde
  ("Ángela" → "Á").
- ViewModel con un repositorio falso: sin sesión no pide nada; **cerrar
  sesión y entrar con otra cuenta muestra la cuenta nueva** (RNF-02);
  `retry()` vuelve a pedir.
- Widget tests: Inicio con nombre, cargando y con error; Perfil con la tarjeta,
  cargando, error y "Reintentar"; la semántica de la tarjeta.
- Manual: en Chrome y en el emulador con tus dos cuentas de prueba.

## 7. Riesgos

- **Datos de la cuenta anterior** al cambiar de cuenta: lo evita mirar
  `sessionProvider` (§3) y tiene su test.
- **Nombres largos** en la tarjeta: se cortan con "…" (§4).
- **Una petición más al entrar**: una sola por sesión, compartida por Inicio y
  Perfil.
