# Memories — App (Flutter)

App de Memories para Android y web, con un solo código Flutter. iOS queda fuera
del MVP.

Producto, decisiones, reglas de negocio, requisitos y arquitectura viven en
Google Drive, carpeta "Proyecto Recuerdos". Aquí solo va lo necesario para
levantar y probar la app. Las reglas para trabajar con Claude Code están en
[CLAUDE.md](CLAUDE.md) y los specs en `specs/`.

El código anterior, escrito con el PRD v3.0, se conserva en el tag
`legacy-prd-v3.0`.

## Requisitos

- **Flutter 3.47.9, canal `stable`** (Dart 3.13.7). Comprueba con
  `flutter --version`; si tienes otra, `flutter channel stable` y
  `flutter upgrade`.
- Chrome, para la versión web.
- Android Studio, solo para el SDK y el emulador de Android.
- El backend (`memories-backend`) levantado según su README, para usar la API.

## Cómo levantarla

```powershell
flutter pub get
```

La URL de la API entra al compilar con `--dart-define=API_BASE_URL=...`; sin
ella, la app no arranca.

**Web** (siempre en el puerto 3000: es el único origen que acepta la API):

```powershell
flutter run -d chrome --web-port 3000 --dart-define=API_BASE_URL=http://localhost:8001
```

**Android** (el emulador llega a tu PC por `10.0.2.2`, no por `localhost`):

```powershell
flutter emulators --launch <id>   # lista los ids con: flutter emulators
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8001
```

## Cómo probarla

```powershell
dart format --set-exit-if-changed .   # formato
flutter analyze                       # análisis estático
flutter test                          # pruebas
```

## Probar el inicio de sesión contra el backend local

**1. Levanta el backend** (`docker compose up -d` en `memories-backend`) y la
app (ver "Cómo levantarla").

**2. Entra con una cuenta verificada.** Si ya tienes una, usa esa y salta al
paso 3. Si no, y mientras no exista la pantalla de registro (F6), créala con
este script: te pide la contraseña sin mostrarla (de 8 a 64 caracteres), crea
`prueba.f5` y la verifica con el correo que llega a Mailpit (no sale a
internet).

```powershell
$clave = Read-Host "Contraseña para la cuenta de prueba" -AsSecureString
$cuenta = @{
  username = 'prueba.f5'; email = 'prueba.f5@ejemplo.pe'
  password = [System.Net.NetworkCredential]::new('', $clave).Password
  first_name = 'Prueba'; paternal_surname = 'Local'
  birth_date = '2000-01-01'; accepts_privacy_policy = $true
}
Invoke-RestMethod -Method Post http://localhost:8001/api/v1/auth/register `
  -ContentType 'application/json' -Body ($cuenta | ConvertTo-Json)
$cuenta = $null

# El correo llega a Mailpit (http://localhost:8025); el token va en el enlace.
Start-Sleep -Seconds 2
$ultimo = (Invoke-RestMethod 'http://localhost:8025/api/v1/messages?limit=1').messages[0]
$texto = (Invoke-RestMethod "http://localhost:8025/api/v1/message/$($ultimo.ID)").Text
$token = [uri]::UnescapeDataString(([regex]::Match($texto, 'token=([^\s&]+)')).Groups[1].Value)
Invoke-RestMethod -Method Post http://localhost:8001/api/v1/auth/verify-email `
  -ContentType 'application/json' -Body (@{ token = $token } | ConvertTo-Json)
```

**3. Revisa esto, en Chrome y en el emulador:**

| Qué haces | Qué debe pasar |
|---|---|
| Entras con una contraseña incorrecta o un correo que no existe | "El usuario o la contraseña no son correctos." |
| Entras con tus datos | Llegas a Inicio ("Tus álbumes") |
| Ya en Inicio, recargas la página (web) o cierras y abres la app (Android) | Sigues en Inicio, sin escribir la contraseña |
| Perfil → Cerrar sesión | Vuelves a Iniciar sesión |
| Después de salir, recargas o reabres | Sigues en Iniciar sesión |
| Pones una contraseña incorrecta seis veces seguidas | "Demasiados intentos. Prueba en N segundos." |

## Cliente de la API

El cliente vive en `packages/memories_api`. Se genera desde el OpenAPI del
backend con openapi-generator (generador `dart-dio`, imagen Docker fijada en el
script) y **no se edita a mano**. Va guardado en el repo, así que el CI no
necesita Docker ni el backend.

Regenéralo cuando el backend cambie un endpoint o un modelo:

1. Abre Docker Desktop y levanta el backend (`docker compose up -d` en
   `memories-backend`). Comprueba que http://localhost:8001/openapi.json abre.
2. Desde la raíz de este repo:

   ```powershell
   powershell -ExecutionPolicy Bypass -File packages/generate_memories_api.ps1
   ```

3. Corre `flutter pub get`, las pruebas de arriba y revisa el diff de
   `packages/memories_api`: muestra qué cambió en el contrato de la API.
4. Sube el resultado en el mismo PR que lo usa.

- El script borra `packages/memories_api` antes de generar. Si falla a la mitad
  (Docker cerrado, backend apagado), recupéralo con
  `git restore packages/memories_api`.
- `packages/memories_api/pubspec.lock` se sube **a propósito**, aunque el
  `.gitignore` generado lo ignore: fija las versiones de `build_runner` y
  `built_value_generator` para que regenerar otro día dé el mismo código.

## Cómo contribuir

1. Crea tu rama desde `main`: `feat/…`, `fix/…`, `chore/…` o `docs/…`.
2. Si es una funcionalidad nueva, primero el spec en `specs/<feature>/`.
3. Abre un Pull Request hacia `main` y completa la plantilla.
4. Revisa tu propio diff y, cuando el CI pase, fusiona tu PR.

`main` está protegido: no acepta push directo, force push ni borrado.
