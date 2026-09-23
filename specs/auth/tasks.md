# Spec: entrar en la app — Tareas

- [x] `TokenStorage` sobre el almacen seguro del sistema
- [x] `ApiClient` con token automatico y renovacion ante 401
- [x] `ApiException` con el formato de error del backend
- [x] Entidades `AppUser` y `AuthSession`
- [x] Contrato `AuthRepository` y su implementacion
- [x] `AuthController` (recuperar sesion, entrar, registrarse, salir)
      · test: `test/features/auth/auth_controller_test.dart`
- [x] Pantallas de inicio de sesion y registro con validacion previa
- [x] Pantalla de perfil con cierre de sesion
- [x] Redireccion automatica segun la sesion (`app_router.dart`)
- [x] Pantalla de carga mientras se comprueba la sesion guardada

## Siguientes

- [ ] Test de widget del formulario de inicio de sesion
- [ ] Editar el nombre desde el perfil (la API ya lo admite)
- [ ] Recuperar la contrasena (necesita el endpoint en el backend)
