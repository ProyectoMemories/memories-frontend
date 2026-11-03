# Memories — App (Flutter)

App de Memories para Android y web, con un solo código Flutter. iOS queda fuera
del MVP.

Producto, decisiones, reglas de negocio, requisitos y arquitectura viven en
Google Drive, carpeta "Proyecto Recuerdos". Aquí solo va lo necesario para
levantar y probar la app. Las reglas para trabajar con Claude Code están en
[CLAUDE.md](CLAUDE.md) y los specs en `specs/`.

El código anterior, escrito con el PRD v3.0, se conserva en el tag
`legacy-prd-v3.0`.

## Cómo levantarla

Se completa con el PR de `chore/flutter-scaffold`.

## Cómo contribuir

1. Crea tu rama desde `main`: `feat/…`, `fix/…`, `chore/…` o `docs/…`.
2. Si es una funcionalidad nueva, primero el spec en `specs/<feature>/`.
3. Abre un Pull Request hacia `main` y completa la plantilla.
4. Revisa tu propio diff y, cuando el CI pase, fusiona tu PR.

`main` está protegido: no acepta push directo, force push ni borrado.
