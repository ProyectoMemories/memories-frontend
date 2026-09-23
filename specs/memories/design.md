# Spec: recuerdos en la app — Diseno

## Pantallas y rutas

| Ruta | Pantalla | Estado |
|---|---|---|
| `/memories` | `MemoriesPage` | `memoriesControllerProvider` |
| `/memories/new` | `MemoryFormPage` | `memoryFormControllerProvider` |
| `/memories/:id` | `MemoryDetailPage` | `memoryDetailProvider(id)` |
| `/memories/:id/edit` | `MemoryFormPage` | detalle + formulario |
| `/calendar` | `CalendarPage` | `mesDelCalendarioProvider`, `calendarioProvider` |
| `/revive` | `RevivePage` | `revivirProvider` |

Las tres principales se envuelven en `HomeShell`, que pone la navegacion
adaptativa. El detalle y el formulario se abren encima (`push`), para que el
gesto de volver funcione como se espera.

## Estado

- `MemoriesController extends AsyncNotifier<PagedMemories>` — listado, busqueda,
  filtros por fecha, pagina siguiente y borrado.
  Al borrar **no recarga la lista**: quita el elemento en memoria, porque
  recargar devolveria el scroll al principio.
- `MemoryFormController extends Notifier<MemoryFormState>` — subida de fotos y
  guardado. Al guardar invalida el listado y el calendario, que se recargaran
  solos la proxima vez que se vean.
- `memoryDetailProvider` / `calendarioProvider` / `revivirProvider` —
  `FutureProvider`, porque son lecturas sin acciones propias.

## Por que se suben las fotos antes de guardar

La API acepta `photo_ids` al crear el recuerdo, no los archivos. Eso permite
subir mientras la persona escribe, que es el momento muerto del flujo. El precio:
si abandona el formulario, quedan fotos huerfanas en el servidor (las limpiara
una tarea del backend, todavia por hacer).

## Fotografias y web

`image_picker` devuelve `XFile`; se lee con `readAsBytes()` y viaja como
`Uint8List`. Ninguna capa usa `dart:io`, asi que el mismo codigo funciona en el
navegador ([ADR 0004](../../docs/adr/0004-un-solo-codigo-para-movil-y-web.md)).

El tipo de contenido se toma de `XFile.mimeType` y, si no viene, de la extension:
el backend valida la firma binaria y rechaza lo que no cuadre.

## Calendario

El endpoint devuelve solo el recuento por dia. La rejilla del mes esta escrita a
mano (`MonthGrid`, unas 90 lineas) en vez de traer una dependencia: un calendario
de un mes no justifica un paquete que mantener.

Al tocar un dia se abre una hoja inferior con los recuerdos de ese dia
(`recuerdosDelDiaProvider`, que filtra por rango de un solo dia).

## Riesgos

| Riesgo | Mitigacion |
|---|---|
| Subir varias fotos grandes con mala conexion | Tiempo maximo de subida mas amplio; la subida es previa y visible |
| URLs firmadas vencidas mientras la pantalla esta abierta | Se piden con cada carga de la lista; si caduca, `errorBuilder` muestra el hueco |
| Listado pesado en la rejilla | Paginado de 20; pendiente: miniaturas en el backend |
