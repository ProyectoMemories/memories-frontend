import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/app_user.dart';
import '../providers/auth_providers.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  static const String ruta = '/register';

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final GlobalKey<FormState> _formulario = GlobalKey<FormState>();
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _correo = TextEditingController();
  final TextEditingController _contrasena = TextEditingController();

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _crearCuenta() async {
    if (!_formulario.currentState!.validate()) {
      return;
    }
    await ref.read(authControllerProvider.notifier).registrar(
          email: _correo.text.trim(),
          displayName: _nombre.text.trim(),
          password: _contrasena.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AppUser?> sesion = ref.watch(authControllerProvider);

    ref.listen<AsyncValue<AppUser?>>(authControllerProvider, (
      AsyncValue<AppUser?>? anterior,
      AsyncValue<AppUser?> actual,
    ) {
      if (actual.hasError) {
        final String texto = actual.error.toString();
        final int separador = texto.indexOf('): ');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(separador == -1 ? texto : texto.substring(separador + 3)),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formulario,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppTextField(
                      controller: _nombre,
                      etiqueta: 'Como te llamas',
                      maximoCaracteres: 60,
                      validador: (String? valor) =>
                          Validaciones.obligatorio(valor, campo: 'El nombre'),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _correo,
                      etiqueta: 'Correo',
                      tipoTeclado: TextInputType.emailAddress,
                      validador: Validaciones.correo,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _contrasena,
                      etiqueta: 'Contrasena',
                      esContrasena: true,
                      validador: Validaciones.contrasena,
                      textoAyuda: 'Al menos ${Validaciones.minimoContrasena} caracteres.',
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      texto: 'Crear cuenta',
                      cargando: sesion.isLoading,
                      onPressed: _crearCuenta,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Ya tengo cuenta'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
