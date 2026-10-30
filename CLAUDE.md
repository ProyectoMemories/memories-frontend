# CLAUDE.md — Memories App (Flutter)

## Rol

Actúas como desarrollador del equipo de Memories (Joey Flores, Victor Avalos,
Victor Vergara). Sigues **Spec-Driven Development**: primero el spec, después el
código. Trabajas por tareas pequeñas y respetas la estructura de este documento.

Este repositorio es **solo la app** (Android y web con un solo código, D51). La
API vive en `memories-backend`, con su propio CLAUDE.md.

---

## 1. Fuente de verdad

Producto, decisiones, reglas de negocio, requisitos y arquitectura viven en
**Google Drive**, carpeta "Proyecto Recuerdos" (D14, D55). En este repositorio
solo hay README técnico, este CLAUDE.md y `specs/`.

| Qué | Dónde (Drive) |
|---|---|
| Decisiones del equipo (D1, D2…) | Context Proyecto para Claude / 01-decisiones |
| Arquitectura | Context Proyecto para Claude / 04-arquitectura |
| Reglas de negocio (RN-xx) | Context Proyecto para Claude / 05-reglas-de-negocio |
| Requisitos (RF-xx, RNF-xx) | Lista de requisitos |
| Mockup oficial | Claude Design, "Memories — Mockup v3", páginas "Recuerdos 4.0" (D50) |

- **No copies esos documentos al repositorio.** Un spec cita los IDs (RF-01,
  RN-67, D57) y el nombre de la pantalla del mockup, sin repetir su contenido.
- Si no puedes leer Drive o algo no está en los documentos, **no lo inventes**:
  dilo y pregunta.
- Si una tarea contradice una decisión o una regla registrada, avisa antes de
  seguir.

## 2. Qué es Memories

Un espacio privado para guardar momentos importantes con su contexto y volver a
ellos con el tiempo. La galería guarda fotos; Memories guarda **el significado**
que alguien decide darles.

- El **álbum** guarda fotos (con fecha y lugar) y descripciones. Tiene un dueño
  y puede compartirse con editores y lectores (D18).
- El **recuerdo** se genera eligiendo y ordenando contenido de un solo álbum y se
  guarda como archivo (collage o páginas tipo libro). Es **inmutable**: solo se
  borra completo (D19, D33, D34).

**Principios que mandan sobre cualquier idea técnica:** el usuario decide; la IA
no es una dependencia; no es una galería; privacidad por defecto; terminar antes
que ampliar.

**Fuera del MVP (no lo construyas aunque parezca fácil):** IA, integraciones con
Google Photos o iCloud, video y audio, funciones sociales, todo lo comercial,
**iOS**, secciones dentro del álbum (D32) y leer EXIF de las fotos (D59, RF-33).
Una idea nueva entra a la Lista de requisitos como "No MVP" y solo pasa al MVP si
los tres lo deciden.

---

## 3. Stack

| Capa | Tecnología |
|---|---|
| Plataformas | Android y web, un solo código (D51). Sin iOS. |
| App | Flutter + Dart |
| Arquitectura | MVVM (D13) |
| Estado | Riverpod: los ViewModels son Notifiers (D57) |
| Cliente de la API | Generado desde el OpenAPI del backend con openapi-generator, generador `dart-dio` (D57) |
| Sesión | Interceptor de dio que renueva el token solo (D56) |
| Pruebas | flutter_test e integration_test (D48) |

## 4. Comandos

Se completan con el PR de `chore/flutter-scaffold`. No inventes comandos que el
repositorio todavía no tiene. Las carpetas de plataforma se crean **sin iOS**:
`--platforms=android,web`.

## 5. Estructura (respétala)

```
CLAUDE.md / CLAUDE.local.md   memoria del proyecto / personal (local, en .gitignore)
README.md                     cómo levantar y probar la app (D55)
.github/                      CI y plantilla de PR
specs/<feature>/              requirements.md, design.md, tasks.md
lib/
├── views/                    pantallas: solo muestran estado y envían acciones
├── view_models/              Notifiers de Riverpod: estado y lógica de cada pantalla
└── repositories/             único punto de acceso a la API (usa el cliente generado)
test/                         espejo de lib/
```

- La carpeta exacta del cliente generado se define en `feat/api-client`.
- No crees carpetas ni archivos de primer nivel sin preguntar.
- Nunca subas `.env`, `CLAUDE.local.md` ni `.claude/settings.local.json`.
- Nombres de archivos, clases y variables **en inglés**, sin tildes.
  Comentarios, specs, commits y textos de la interfaz, **en español**.
- Las features se llaman igual que los módulos del backend: `auth`, `users`,
  `albums`, `memories`.

---

## 6. Flujo obligatorio: Spec-Driven Development

1. **Sin spec no hay código.** Antes de implementar, comprueba que existe
   `specs/<feature>/`. Si no existe, créala y **detente** para que la revisemos.
2. **requirements.md**: historias de usuario y criterios de aceptación
   verificables (Dado / Cuando / Entonces). Cita los RF, RN y D de Drive y las
   pantallas del mockup.
3. **design.md**: pantallas, ViewModels, estados (cargando, error, vacío),
   endpoints que consume y riesgos. Una decisión de arquitectura nueva no se
   decide en el spec: se propone al equipo y, si se aprueba, se registra en el
   01 de Drive.
4. **tasks.md**: tareas pequeñas, ordenadas por dependencia, cada una con su
   test. Se marcan `[x]` al terminar.
5. Implementa **una tarea a la vez**. Antes de cerrarla: tests, análisis
   estático y formato en verde.
6. Si la implementación se desvía del spec, **actualiza el spec primero** y
   avisa.

## 7. Reglas de arquitectura (MVVM, D13, D57)

- **Las vistas no llaman a la API ni a los repositorios**: hablan con su
  ViewModel.
- **Un ViewModel no conoce widgets**; se prueba sin levantar pantallas.
- **Solo los repositorios** usan el cliente generado. Una vista nunca ve tipos
  de dio ni modelos generados.
- **El cliente generado no se edita a mano**: se regenera desde el OpenAPI.
- **Nada de `dart:io` en código compartido**: rompe la web.
- **Un solo diseño adaptativo** para Android y web, no dos apps.
- La configuración (URL de la API, entorno) entra por variables de compilación,
  nunca escrita en el código.
- SOLID con criterio: nada de abstracciones sin un segundo caso de uso real.
- Funciones pequeñas, nombres explícitos, sin código muerto. Un comentario
  explica **por qué**, no **qué**.
- Errores explícitos: nada de `catch` vacíos.

## 8. Sesión (D56, RN-67)

- Token de acceso de 15 minutos; token de renovación de 30 días que **cambia en
  cada uso**.
- **Android:** los dos tokens van al almacenamiento seguro del sistema.
- **Web:** el token de renovación lo guarda el navegador en una cookie
  `HttpOnly` que el código **no puede leer**; la app no lo guarda en ningún
  otro lado (ni `localStorage` ni `sessionStorage`). El token de acceso vive
  solo en memoria.
- El interceptor de dio renueva el token cuando la API responde que venció.
  **Las renovaciones van de una en una**: si dos peticiones fallan a la vez, se
  renueva una sola vez y ambas esperan. Dos renovaciones simultáneas con el
  mismo token se ven como reuso y la API revoca la sesión.
- Cerrar sesión llama a la API (revoca la sesión) y luego borra los tokens
  locales.

## 9. Seguridad y privacidad

- **La lógica de acceso vive en la API, jamás en el cliente** (RNF-01, RNF-02).
  La app puede ocultar un botón según el rol, pero quien decide es la API.
- Un recurso ajeno llega como **404** (D60): la app lo muestra como "no
  encontrado", sin insinuar que existe.
- Nada de secretos en el repositorio.
- No registres tokens ni contraseñas en consola ni en logs.
- Antes de agregar una dependencia, justifícala y comprueba que esté mantenida.

## 10. Pruebas

- Toda lógica nueva lleva test; un bug arreglado lleva un test que lo reproduce.
- Los ViewModels se prueban con un `ProviderContainer` y un doble del
  repositorio: sin servidor.
- Las pantallas complejas llevan un test de widget del flujo principal;
  integration_test para los flujos de extremo a extremo.

## 11. Git

Flujo de D61:

- Cada integrante trabaja en **su propia rama**: `feat/…`, `fix/…`, `chore/…`,
  `docs/…`. **Nunca commits directos a `main`** (está protegido).
- Todo entra a `main` por **Pull Request** desde esa rama. El autor puede
  fusionar su propio PR; no se exige la aprobación de otro integrante.
- Cuando exista el CI, el PR debe pasarlo antes de fusionarse.
- Como nadie más revisa, **revisa tu propio PR antes de fusionarlo**: lee el
  diff completo y completa la lista de la plantilla.
- Commits pequeños con Conventional Commits, en español:
  `feat(auth): pantalla de inicio de sesión`. Un commit = un cambio lógico.

## 12. Cómo trabajar conmigo

- Responde en español, concreto y breve.
- Si algo es ambiguo, **pregunta antes de asumir**.
- Dame feedback honesto: si mi enfoque está mal o desactualizado, dilo y propón
  una alternativa.
- Al terminar una tarea, resume en 2 o 3 líneas qué cambió y qué falta.
