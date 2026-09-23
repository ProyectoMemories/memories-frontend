# Spec: recuerdos en la app — Tareas

## Dominio y datos

- [x] Entidades `Memory`, `MemoryPhoto`, `CalendarDay`, `ReviveResult`, `PagedMemories`
- [x] Contrato `MemoryRepository`
- [x] `MemoryDto` con la traduccion del JSON
      · test: `test/features/memories/memory_dto_test.dart`
- [x] `MemoryRemoteDataSource` (incluida la subida multipart por bytes)
- [x] `MemoryRepositoryImpl`

## Estado

- [x] `MemoriesController`: listado, busqueda, pagina siguiente y borrado local
- [x] `MemoryFormController`: elegir fotos, subirlas, guardar
- [x] Providers de detalle, calendario y revivir

## Pantallas

- [x] Lista con rejilla adaptativa, buscador y estado vacio
- [x] Formulario de creacion con miniaturas y selector de fecha
- [x] Edicion de titulo, fecha y descripcion
- [x] Detalle con las fotos deslizables y borrado con confirmacion
- [x] Calendario mensual propio con detalle por dia
- [x] Revivir con su motivo

## Pendientes

- [ ] Anadir y quitar fotografias desde la edicion (la API ya lo admite)
- [ ] Test de widget del formulario de creacion
- [ ] Miniaturas cuando el backend las genere
- [ ] Filtro por rango de fechas en la lista (el controlador ya lo soporta, falta
      la interfaz)
