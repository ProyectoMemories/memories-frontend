# Spec: recuerdos en la app — Requisitos

- Capacidades del PRD: CP-01 a CP-06 y CP-08
- Contrato de la API: `specs/memories/` del repositorio `memories-backend`
- Estado: implementado

## Historias de usuario

### HU-01 — Crear un recuerdo (CP-01, CP-02)

> Como persona que acaba de vivir algo importante, quiero elegir fotos del
> telefono y contar que paso, para no perder el contexto.

- Dado que abro "nuevo recuerdo", cuando elijo fotos de la galeria, entonces se
  van subiendo mientras escribo y las veo en miniatura.
- Dado que no he anadido ninguna foto, entonces el boton de guardar esta
  desactivado y se explica por que (no es un error al pulsar: es un boton que no
  deja pulsarse).
- Dado que quito una miniatura, entonces esa foto deja de formar parte del
  recuerdo.
- Dada la fecha, cuando la elijo, entonces no puedo elegir una posterior a hoy.
- Dado que guardo, entonces vuelvo a la lista y el recuerdo nuevo aparece.

### HU-02 — Ver mis recuerdos (CP-03)

- Dado que tengo recuerdos, cuando abro la app, entonces los veo en una rejilla
  con su foto de portada, titulo y fecha.
- Dada una rejilla, cuando la pantalla es mas ancha, entonces caben mas columnas
  (2 en movil, 3 en tableta, 4 en escritorio).
- Dado que escribo en el buscador, cuando confirmo, entonces solo veo los que
  coinciden.
- Dado que no tengo ninguno, entonces veo una pantalla que invita a crear el
  primero, no una lista vacia.
- Dado que llego al final de la lista, entonces se carga la pagina siguiente
  sola.

### HU-03 — Detalle, edicion y borrado (CP-03, CP-04)

- Dado un recuerdo, cuando lo abro, entonces veo sus fotos deslizables, el
  titulo, la fecha y la descripcion.
- Dado que edito, entonces puedo cambiar titulo, fecha y descripcion.
- Dado que borro, entonces se me pide confirmacion y se avisa de que no se puede
  deshacer.

### HU-04 — Calendario (CP-08)

- Dado un mes, cuando lo abro, entonces veo los dias que tienen recuerdos
  marcados y cuantos hay en cada uno.
- Dado un dia con recuerdos, cuando lo toco, entonces veo su lista y puedo abrir
  cualquiera.
- Dado un mes sin recuerdos, entonces se dice claramente, sin parecer un error.

### HU-05 — Revivir (CP-05)

- Dado que hay recuerdos de este dia en anos anteriores, cuando abro "revivir",
  entonces los veo bajo el titulo "Un dia como hoy".
- Dado que no los hay, entonces veo una seleccion al azar.
- Dado que no tengo recuerdos, entonces se me explica que aun no hay nada que
  revivir.

## Fuera de esta feature

Albumes compartidos, edicion de fotos, filtros por ubicacion, y cualquier
ordenacion automatica.
