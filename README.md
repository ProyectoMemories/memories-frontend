# Memories — App

Aplicacion de [Memories](docs/product/prd-resumen.md) en Flutter: **un solo
codigo para Android y web**. iOS y escritorio quedan fuera del MVP.

Flutter 3.47.7 · Dart 3.13.5 · Riverpod · go_router · Dio.

La API vive en el repositorio `memories-backend`.

---

## Versiones del equipo

Los tres usamos las mismas versiones. Si una no coincide, el proyecto puede
compilar en una maquina y fallar en otra.

| Herramienta | Version |
|---|---|
| Flutter | 3.47.7, canal `stable` (incluye Dart 3.13.5) |
| Android SDK Platform | la que pida el proyecto (Gradle la instala sola) |
| Android NDK | **28.2.13676358** |
| Java (para Gradle) | 17, la que trae Android Studio |
| Editor | VS Code |

## Instalacion (Windows, una sola vez)

Android Studio **solo** se usa para instalar el SDK de Android y el emulador.
Se programa en VS Code.

### 1. Git y rutas largas

Instala Git desde git-scm.com. Luego, en PowerShell **como administrador**:

```powershell
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name LongPathsEnabled -Value 1 -PropertyType DWORD -Force
git config --global core.longpaths true
```

Sin esto, Windows no puede borrar ni mover la carpeta `build/` (rutas de mas
de 260 caracteres).

### 2. Flutter

```powershell
git clone https://github.com/flutter/flutter.git -b stable C:\src\flutter
```

- Usa una ruta sin espacios ni tildes.
- Agrega `C:\src\flutter\bin` al **Path de usuario** (Variables de entorno).
- Cierra **todas** las terminales y editores, y vuelve a abrirlos.
- Verifica con `flutter --version`: debe decir 3.47.7 y canal `stable`. Si
  `stable` ya avanzo a una version mas nueva, avisa al equipo antes de seguir:
  los tres actualizan juntos.

### 3. Android Studio

1. Instala Android Studio (developer.android.com/studio) con la opcion
   *Standard*.
2. *File → Settings → Languages & Frameworks → Android SDK → SDK Tools*.
3. Marca **Show Package Details** (abajo a la derecha). Sin esto solo se ve
   la ultima version de cada paquete.
4. Instala:
   - Android SDK Build-Tools
   - Android SDK Command-line Tools (latest)
   - Android SDK Platform-Tools
   - Android Emulator
   - **NDK (Side by side) → 28.2.13676358** (exactamente esa)
5. *Apply* y espera a que termine.

No instales en Android Studio plugins de Flutter, Dart ni agentes de IA.

### 4. Conectar Flutter con el SDK

```powershell
flutter config --android-sdk "$env:LOCALAPPDATA\Android\Sdk"
flutter doctor
```

Deben salir en verde **Flutter**, **Android toolchain** y **Chrome**. Visual
Studio puede quedar en rojo: solo sirve para apps de escritorio Windows.

Opcional: agrega `%LOCALAPPDATA%\Android\Sdk\platform-tools` al Path de
usuario para tener el comando `adb`.

### 5. Emulador

En Android Studio: *Device Manager → + → Create Virtual Device → Pixel*, con
la imagen recomendada (x86_64).

Si el emulador va lento o se queda en negro, actualiza el driver de tu tarjeta
de video. Con menos de 16 GB de RAM, usa una imagen con un API anterior.

### 6. VS Code

Instala las extensiones **Flutter** (instala Dart con ella) y **Claude Code**.

### 7. Clonar el proyecto

```powershell
git clone https://github.com/ProyectoMemories/memories-frontend
cd memories-frontend
flutter pub get
flutter analyze
flutter test
```

Las carpetas `android/` y `web/` ya estan en el repositorio: **no corras
`flutter create .`**.

---

## Arrancar

### Requisito: la API

La app necesita la API corriendo. Como levantarla se explica en el README de
`memories-backend`. Antes de arrancar la app, comprueba que
`http://localhost:8001/docs` abre en el navegador.

### App

| Donde | Comando |
|---|---|
| Chrome | `flutter run -d chrome --dart-define-from-file=env/dev.json` |
| Firefox u otro navegador | `flutter run -d web-server --web-port 8080 --dart-define-from-file=env/dev.json` y abre `http://localhost:8080` |
| Emulador Android | ver abajo |

Emulador Android:

```powershell
flutter emulators                          # lista los emuladores
flutter emulators --launch <id>            # enciende uno
flutter devices                            # espera a ver emulator-5554
flutter run -d emulator-5554 --dart-define-from-file=env/dev.android.json
```

La primera compilacion de Android tarda varios minutos (Gradle descarga sus
dependencias). Las siguientes son rapidas.

Con la app corriendo: `r` recarga los cambios, `R` reinicia y `q` cierra.

### Configuracion por entorno

La URL de la API nunca se escribe en el codigo: entra por
`--dart-define-from-file` y se lee en `lib/core/config/app_config.dart`.

| Archivo | Para que |
|---|---|
| `env/dev.json` | Web y escritorio: la API en `localhost:8001` |
| `env/dev.android.json` | Emulador: la API en `10.0.2.2:8001`, porque dentro del emulador `localhost` es el propio emulador |
| `env/prod.example.json` | Plantilla del despliegue |

---

## Trabajo diario

```powershell
flutter test                 # pruebas
flutter analyze              # analisis estatico
dart format .                # formato (el CI lo exige)
flutter build web --release  # compilado de web
flutter build apk --release  # compilado de Android
```

Antes de abrir un PR, los tres primeros tienen que pasar sin errores: es lo
mismo que revisa el CI (`.github/workflows/ci.yml`).

---

## Como esta organizado

```
lib/
├── core/        configuracion, red, almacenamiento, rutas, tema, utilidades
├── shared/      layout adaptativo y widgets comunes
└── features/<feature>/
    ├── domain/         entidades y contratos (sin Flutter ni Dio)
    ├── data/           DTOs, fuentes remotas e implementacion de los contratos
    └── presentation/   providers, controladores (ViewModels) y pantallas
```

Los `features` se llaman igual que los modulos del backend.

Detalle en [docs/arquitectura.md](docs/arquitectura.md) y en
[docs/adr/](docs/adr/). Las reglas de trabajo, en [CLAUDE.md](CLAUDE.md).

## Pantallas

| Ruta | Que hace |
|---|---|
| `/login`, `/register` | Entrar y crear cuenta |
| `/memories` | Lista de recuerdos con busqueda |
| `/memories/new` | Crear: elegir fotos, titulo, fecha y descripcion |
| `/memories/:id` | Detalle y borrar |
| `/memories/:id/edit` | Editar titulo, fecha y descripcion |
| `/calendar` | Recuerdos por dia del mes |
| `/revive` | Volver a descubrir recuerdos |
| `/profile` | Perfil y cerrar sesion |
