import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/layout/breakpoints.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/app_user.dart';
import '../providers/auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  static const String ruta = '/login';

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final GlobalKey<FormState> _formulario = GlobalKey<FormState>();
  final TextEditingController _correo = TextEditingController();
  final TextEditingController _contrasena = TextEditingController();

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formulario.currentState!.validate()) {
      return;
    }
    await ref.read(authControllerProvider.notifier).iniciarSesion(
          email: _correo.text.trim(),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_mensaje(actual.error!))),
        );
      }
    });

    return Scaffold(
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
                    Icon(
                      Icons.auto_stories_outlined,
                      size: Breakpoints.esMovil(context) ? 56 : 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Memories',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Guarda lo que importa y vuelve a ello.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
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
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      texto: 'Entrar',
                      cargando: sesion.isLoading,
                      onPressed: _entrar,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text('No tengo cuenta'),
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

  String _mensaje(Object error) {
    final String texto = error.toString();
    final int separador = texto.indexOf('): ');
    return separador == -1 ? texto : texto.substring(separador + 3);
  }
}
