# Auth en la app — tareas

Una tarea por commit; cada una con su test y `/check` en verde. Un PR por paso
(F3 a F7). No se empieza hasta que el equipo apruebe la spec y las cuatro
decisiones de `design.md` §2.

## F3 · Cliente de la API (`feat/api-client`)

- [x] Script o comando documentado que genera `packages/memories_api` con la
      imagen fijada de openapi-generator (`dart-dio`) desde
      `http://localhost:8001/openapi.json` · test: el paquete compila y
      `flutter analyze` pasa
- [ ] La app depende del paquete local · test: un test crea el cliente con la
      `API_BASE_URL` de `app_config.dart`
- [ ] README y CLAUDE.md §4: cómo regenerar el cliente cuando cambia la API

## F4 · Sesión (`feat/auth-session`)

- [ ] `TokenStore`: Android con `flutter_secure_storage`; web solo en memoria ·
      tests con un doble del almacenamiento
- [ ] `AuthRepository`: login, refresh, logout, con errores propios por `code`
      (design §6) · tests con dio falso
- [ ] Interceptor: renueva con `access_token_expired` y repite; una sola
      renovación a la vez · test: dos 401 simultáneos = un refresh
- [ ] `SessionNotifier` (comprobando / con sesión / sin sesión) · test con
      `ProviderContainer`
- [ ] Web: dio con `withCredentials: true` · test del adaptador configurado

## F5 · Iniciar sesión (`feat/auth-login`) · cierra P20

- [ ] Tema (`lib/views/theme/`) con los tokens de design §3 y las fuentes
      confirmadas · test: el `ThemeData` usa los tokens
- [ ] Componentes compartidos (campo, campo de contraseña, botones, aviso) ·
      widget tests
- [ ] `go_router` con redirecciones según `SessionNotifier` · tests de rutas
- [ ] Pantalla y `LoginViewModel` · tests del ViewModel y widget test del flujo
- [ ] Inicio y Perfil provisionales; cerrar sesión · tests
- [ ] Android: tráfico sin cifrar solo en `debug` · se comprueba con el
      emulador
- [ ] Prueba manual en Chrome (puerto 3000) y en el emulador contra el Docker
      del backend; README actualizado

## F6 · Registro y verificación (`feat/auth-register`)

- [ ] `RegisterViewModel` (dos pasos, edad, usuario D40) · tests
- [ ] Pantallas Registro 1, Registro 2 y Menor de 14 · widget tests
- [ ] Revisa tu correo y reenviar · tests
- [ ] `/verify-email?token=` · tests de verificado y vencido
- [ ] Prueba manual: registro real y enlace desde Mailpit

## F7 · Contraseñas (`feat/auth-password`)

- [ ] Recuperar contraseña y aviso de enlace enviado · tests
- [ ] `/reset-password?token=` (no coinciden, vencido, listo) · tests
- [ ] Cambiar contraseña desde Perfil (actual incorrecta, listo) · tests
- [ ] `integration_test` del recorrido completo contra el backend local
- [ ] Prueba manual de todo auth en Chrome y en el emulador (D78)
