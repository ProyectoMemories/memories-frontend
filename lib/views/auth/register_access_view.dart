import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../view_models/auth/register_view_model.dart';
import '../app_router.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_checkbox_row.dart';
import '../widgets/app_password_field.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_layouts.dart';
import '../widgets/form_error_text.dart';

/// Crear cuenta, paso 2 (HU-02): pantalla "Registro 2: acceso" del mockup.
class RegisterAccessView extends ConsumerStatefulWidget {
  const RegisterAccessView({super.key});

  @override
  ConsumerState<RegisterAccessView> createState() => _RegisterAccessViewState();
}

class _RegisterAccessViewState extends ConsumerState<RegisterAccessView> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _acceptsPrivacyPolicy = false;

  @override
  void initState() {
    super.initState();
    // Sin el paso 1 (por ejemplo, al recargar en web) no hay qué enviar.
    if (ref.read(registerViewModelProvider).personalData == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.register);
      });
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final result = await ref
        .read(registerViewModelProvider.notifier)
        .submit(
          username: _username.text,
          email: email,
          password: _password.text,
          acceptsPrivacyPolicy: _acceptsPrivacyPolicy,
        );
    if (!mounted) return;
    switch (result) {
      case SubmitResult.registered:
        context.go(AppRoutes.checkEmail, extra: email);
      case SubmitResult.underage:
        context.go(AppRoutes.registerUnderage);
      case SubmitResult.failed:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerViewModelProvider);
    final errors = state.errors;
    final enabled = !state.isSubmitting;

    return AuthFormScaffold(
      topBar: AuthTopBar(
        title: 'Crear cuenta',
        onBack: () => context.go(AppRoutes.register),
      ),
      progress: const StepProgress(current: 2, total: 2),
      title: 'Tus datos de acceso',
      footer: PrimaryButton(
        label: 'Crear cuenta',
        onPressed: _submit,
        isLoading: state.isSubmitting,
      ),
      children: [
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Nombre de usuario',
                controller: _username,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newUsername],
                helperText:
                    'De 3 a 30: letras sin tildes, números, punto y guion '
                    'bajo.',
                errorText: errors[RegisterField.username],
                enabled: enabled,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Correo',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                errorText: errors[RegisterField.email],
                enabled: enabled,
              ),
              const SizedBox(height: 12),
              AppPasswordField(
                label: 'Contraseña',
                controller: _password,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                helperText: 'De 8 a 64 caracteres.',
                errorText: errors[RegisterField.password],
                enabled: enabled,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Sin enlace ni versión hasta que exista la página de la política
        // (design §7, [PENDIENTE]).
        AppCheckboxRow(
          value: _acceptsPrivacyPolicy,
          onChanged: (value) => setState(() => _acceptsPrivacyPolicy = value),
          label:
              'Acepto la política de privacidad y el tratamiento de mis '
              'datos personales.',
          errorText: errors[RegisterField.privacyPolicy],
          enabled: enabled,
        ),
        if (state.errorMessage case final message?) ...[
          const SizedBox(height: 14),
          FormErrorText(message),
        ],
      ],
    );
  }
}
