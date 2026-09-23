# ADR 0001 — Clean Architecture por feature (y su relacion con MVVM)

- Estado: aceptada
- Fecha: 2026-09-22

## Contexto

La app tiene que crecer sin convertirse en una carpeta de pantallas que llaman a
la API desde cualquier sitio. En CRIS, el frontend (Angular) se organizo por
features con `pages/`, `data-access/`, `application/` y `models/`, y funciono: la
regla "las vistas no llaman a la API, solo los servicios" evito el desorden.

Aqui se busca lo mismo, alineado ademas con la arquitectura del backend.

## Decision

Estructura **por feature** y, dentro, tres capas:

```
features/<feature>/
├── domain/         entidades + contrato del repositorio (Dart puro)
├── data/           DTOs, fuente remota, implementacion del contrato
└── presentation/   providers, controladores y pantallas
```

- `domain/` no importa Flutter, ni Dio, ni Riverpod.
- `presentation/` depende del **contrato** del repositorio, no de su
  implementacion: por eso los tests de controladores no necesitan servidor.
- Los `features` se llaman igual que los modulos del backend (`auth`,
  `memories`).

**Sobre MVVM:** un controlador de Riverpod *es* el ViewModel: guarda el estado de
la pantalla, expone acciones y no conoce widgets. La vista solo lee el estado y
llama a sus metodos. Asi que esto es MVVM, con las capas de datos separadas de
forma explicita.

**Sin clases de caso de uso por cada lectura.** En el backend cada caso de uso es
un archivo porque ahi viven las reglas de negocio. En la app, la mayoria de esas
"acciones" serian una linea que llama al repositorio. Se aplica YAGNI: la logica
que si existe (subir fotos y despues crear el recuerdo) vive en el controlador
correspondiente. Cuando una regla se repita en dos pantallas, entonces si se
extrae.

## Consecuencias

- Cambiar la API toca `data/`; cambiar el diseno toca `presentation/`; el dominio
  casi nunca se mueve.
- Los tests del controlador de sesion corren en milisegundos con un doble del
  repositorio.
- Hay algo de codigo repetido en los DTOs (traducciones a mano), que es
  deliberado: ver [ADR 0003](0003-sin-generacion-de-codigo.md).
