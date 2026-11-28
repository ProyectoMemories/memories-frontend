# Users en la app — tareas

Una tarea por commit; cada una con su test y `/check` en verde. Spec aprobada
el 2026-11-28.

## U1 · Nombre en Inicio y Perfil (`feat/profile-name`)

- [x] Cliente regenerado con `GET /users/me` (`packages/generate_memories_api.ps1`) · test: `flutter analyze` pasa
- [x] `UsersRepository.myProfile()` y `Profile` (`displayName`, `initials`) · tests con un doble de dio
- [x] `myProfileProvider` que sigue la sesión · tests: sin sesión no pide; cambiar de cuenta muestra la nueva; `retry()`
- [x] Saludo con el nombre en Inicio · widget tests: con nombre, cargando y con error
- [ ] `ProfileHeader` en Perfil · widget tests: datos, cargando, error con "Reintentar" y semántica
- [ ] README (cómo probarlo) y nota en `specs/auth` (HU-07 y riesgos ya no esperan a `users`)
- [ ] Prueba manual en Chrome (puerto 3000) y en el emulador con las dos cuentas de prueba
