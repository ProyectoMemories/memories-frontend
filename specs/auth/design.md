# Spec: entrar en la app — Diseno

## Pantallas

| Ruta | Pantalla | Estado que consume |
|---|---|---|
| `/login` | `LoginPage` | `authControllerProvider` |
| `/register` | `RegisterPage` | `authControllerProvider` |
| `/profile` | `ProfilePage` | `authControllerProvider` |

Mientras `authControllerProvider` esta cargando, `app.dart` muestra la pantalla
de carga y `go_router` no decide nada.

## Estado

`AuthController extends AsyncNotifier<AppUser?>`:

- `build()` — recupera la sesion guardada (o `null`).
- `iniciarSesion`, `registrar`, `cerrarSesion`, `actualizarNombre`.
- `sesionExpirada()` — la llama `ApiClient` cuando la renovacion falla.

`null` significa "nadie dentro"; un `AppUser` significa "sesion abierta". El
router observa este provider (`refreshListenable`) y redirige.

## Flujo del token

```
peticion → interceptor anade "Authorization: Bearer <acceso>"
   ↓ 401
renovar con el token de refresco (una sola vez, compartida)
   ├─ ok    → se reintenta la peticion original, la persona no nota nada
   └─ falla → se borran los tokens y AuthController vacia el estado
```

La renovacion usa un `Dio` aparte para no entrar en bucle con el propio
interceptor.

## Capas

| Capa | Archivos |
|---|---|
| `domain` | `AppUser`, `AuthSession`, `AuthRepository` (contrato) |
| `data` | `UserDto`, `SessionDto`, `AuthRemoteDataSource`, `AuthRepositoryImpl` |
| `presentation` | `auth_providers.dart`, `AuthController`, tres pantallas |
| `core` | `ApiClient`, `TokenStorage` |

## Riesgos

| Riesgo | Mitigacion |
|---|---|
| Varias peticiones fallan a la vez y disparan varias renovaciones | Una sola renovacion compartida (`_refreshInFlight`) |
| El almacen seguro en web es mas debil | Token de acceso corto y rotacion del de refresco |
| La app se queda en la pantalla de carga si la API no responde | La peticion tiene tiempo maximo; al fallar, se vuelve al inicio de sesion |
