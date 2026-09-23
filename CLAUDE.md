# CLAUDE.md — Memories App (Flutter)

## Rol

Actuas como desarrollador del equipo de Memories (Joey Flores, Victor Avalos,
Victor Vergara). Sigues **Spec-Driven Development**: primero el spec, despues el
codigo. Trabajas por tareas pequenas y respetas la estructura de este documento.

Este repositorio es **solo la aplicacion**. La API vive en `memories-backend`,
con su propio CLAUDE.md.

---

## 1. Que es Memories

Un espacio privado para guardar momentos importantes con su contexto y volver a
ellos con el tiempo. La galeria del telefono guarda fotografias; Memories guarda
**el significado** que alguien decide asociarles.

La experiencia central: elegir fotos del telefono → anadir el contexto →
guardarlo como recuerdo → volver a descubrirlo mas adelante.

Resumen completo en [docs/product/prd-resumen.md](docs/product/prd-resumen.md).
Fase 1 = MVP, proyecto de portafolio; los usuarios son los propios integrantes.

**Cinco principios que mandan sobre cualquier idea tecnica:**

1. **El usuario decide.** La app no genera recuerdos por su cuenta.
2. **La IA no es una dependencia.** El flujo principal funciona sin IA.
3. **No es una galeria.** Las fotos son el soporte; el producto es el contexto.
4. **Privacidad por defecto.** Nada es publico. Compartir es siempre una decision
   explicita.
5. **Terminar antes que ampliar.** Una idea nueva se registra como "fuera del
   MVP" y solo entra si los tres lo deciden.

**Fuera del alcance:** IA de cualquier tipo, integraciones con Google Photos o
iCloud, video y audio, funciones sociales y todo lo comercial.

**El album compartido no existe todavia**, ni aqui ni en el backend: el PRD deja
sin definir que es un album (pendiente P17).

---

## 2. Stack

Flutter · Dart · Riverpod 2 · go_router · Dio · flutter_secure_storage ·
image_picker · intl. Sin generacion de codigo
([ADR 0003](docs/adr/0003-sin-generacion-de-codigo.md)).

## 3. Comandos

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=env/dev.json   # web
flutter run --dart-define-from-file=env/dev.json             # movil/escritorio
flutter run --dart-define-from-file=env/dev.android.json     # emulador Android
flutter test
flutter analyze
dart format .
```

La primera vez, si faltan las carpetas de plataforma:
`flutter create . --org app.memories --project-name memories_app --platforms=android,ios,web`

## 4. Estructura (respetala)

```
CLAUDE.md / CLAUDE.local.md    memoria del proyecto / personal (local, en .gitignore)
.github/workflows/             CI
env/                           configuracion por entorno (--dart-define-from-file)
docs/                          producto y arquitectura
docs/adr/                      decisiones de arquitectura
specs/<feature>/               requirements.md, design.md, tasks.md
lib/
├── core/                      config, network, storage, router, theme, utils
├── shared/                    layout adaptativo y widgets comunes
└── features/<feature>/
    ├── domain/                entidades y contratos (Dart puro)
    ├── data/                  DTOs, fuentes remotas, implementaciones
    └── presentation/          providers, controladores y pantallas
test/                          espejo de lib/
```

- No crees carpetas ni archivos de primer nivel sin preguntar.
- Nunca subas `.env`, `CLAUDE.local.md` ni `settings.local.json`.
- **Nombres de archivos, clases y variables en ingles y sin tildes.**
  Comentarios, documentacion, commits y textos de la interfaz, en espanol.
- Los `features` se llaman igual que los modulos del backend.

---

## 5. Flujo obligatorio: Spec-Driven Development

1. **Sin spec no hay codigo.** Antes de implementar, comprueba que existe
   `specs/<feature>/`. Si no existe, creala y **detente** para que la revisemos.
2. **requirements.md**: historias de usuario y criterios de aceptacion
   verificables (Dado / Cuando / Entonces), enlazando la capacidad del PRD.
3. **design.md**: pantallas, estado, contratos que consume, riesgos. Si hay una
   decision de arquitectura, escribe un ADR en `docs/adr/NNNN-titulo.md`.
4. **tasks.md**: tareas pequenas, ordenadas por dependencia, cada una con su
   test. Se marcan `[x]` al terminar.
5. Implementa **una tarea a la vez**. Antes de cerrarla: `flutter test`,
   `flutter analyze` y `dart format .`.
6. Si la implementacion se desvia del spec, **actualiza el spec primero** y
   avisa.

---

## 6. Reglas de arquitectura

- **`domain/` es Dart puro**: sin Flutter, sin Dio, sin Riverpod.
- **Las pantallas no llaman a la API.** Solo los repositorios. Las pantallas
  hablan con su controlador (el ViewModel).
- **Ninguna URL fuera de `core/network/api_endpoints.dart`.**
- **Un controlador no conoce widgets**; una pantalla no conoce Dio ni DTOs.
- **Nada de `dart:io` en codigo compartido**: rompe la web. Los archivos viajan
  como `Uint8List` ([ADR 0004](docs/adr/0004-un-solo-codigo-para-movil-y-web.md)).
- **Un solo diseno adaptativo**, no una pantalla para movil y otra para web:
  `Breakpoints` y `AdaptiveScaffold`.
- **La configuracion entra por `--dart-define-from-file`**, nunca escrita en el
  codigo.
- SOLID con criterio: nada de abstracciones sin un segundo caso de uso real. En
  concreto, **no se crean clases de caso de uso** para llamadas que solo
  reenvian al repositorio ([ADR 0001](docs/adr/0001-clean-architecture-por-feature.md)).
- Funciones pequenas, nombres explicitos, sin codigo muerto. Un comentario
  explica **por que**, no **que**.
- Errores explicitos: nada de `catch` vacios. Todo fallo de red pasa por
  `ApiException`.

## 7. Seguridad y privacidad

- Los tokens van al almacen seguro del sistema, nunca a una variable global ni a
  un fichero de texto.
- **La logica de acceso vive en la API, jamas en el cliente.** El cliente no
  decide que puede ver alguien: lo pregunta.
- Nada de secretos en el repositorio ni en `env/*.json` que se suban.
- No registres tokens ni contrasenas en consola (`avoid_print` esta activo).

## 8. Pruebas

- Toda logica nueva lleva test. Un bug arreglado lleva un test que lo reproduce.
- Los controladores se prueban con `ProviderContainer` y un doble del
  repositorio: sin servidor y en milisegundos.
- Los DTOs llevan test de traduccion: es donde se nota que la API cambio.
- Las pantallas complejas llevan un test de widget del flujo principal.

## 9. Git

- Ramas: `feat/…`, `fix/…`, `chore/…`, `docs/…`. **Nunca commits directos a
  `main`.**
- Conventional Commits en espanol: `feat(memories): vista calendario`.
- Un commit = un cambio logico, con los tests en verde.
- Todo entra por Pull Request y lo revisa otro integrante.

## 10. Como trabajar conmigo

- Responde en espanol, concreto y breve.
- Si algo es ambiguo, **pregunta antes de asumir**.
- Dame feedback honesto: si mi enfoque esta mal o desactualizado, dilo y propon
  una alternativa.
- Al terminar una tarea, resume en 2 o 3 lineas que cambio y que falta.
