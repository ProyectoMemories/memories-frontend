import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../view_models/auth/register_view_model.dart';
import '../app_router.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_date_field.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_layouts.dart';

/// Crear cuenta, paso 1 (HU-02): pantalla "Registro 1: datos" del mockup.
class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _firstName = TextEditingController();
  final _paternalSurname = TextEditingController();
  final _maternalSurname = TextEditingController();
  DateTime? _birthDate;

  @override
  void dispose() {
    _firstName.dispose();
    _paternalSurname.dispose();
    _maternalSurname.dispose();
    super.dispose();
  }

  void _next() {
    final result = ref
        .read(registerViewModelProvider.notifier)
        .next(
          firstName: _firstName.text,
          paternalSurname: _paternalSurname.text,
          maternalSurname: _maternalSurname.text,
          birthDate: _birthDate,
        );
    switch (result) {
      case NextStepResult.ready:
        context.go(AppRoutes.registerAccess);
      case NextStepResult.underage:
        context.go(AppRoutes.registerUnderage);
      case NextStepResult.incomplete:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final errors = ref.watch(registerViewModelProvider).errors;
    final today = ref.watch(todayProvider)();

    return AuthFormScaffold(
      topBar: AuthTopBar(
        title: 'Crear cuenta',
        onBack: () => context.go(AppRoutes.login),
      ),
      progress: const StepProgress(current: 1, total: 2),
      title: 'Cuéntanos quién eres',
      footer: PrimaryButton(label: 'Siguiente', onPressed: _next),
      children: [
        AppTextField(
          label: 'Nombre',
          controller: _firstName,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.givenName],
          errorText: errors[RegisterField.firstName],
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Apellido paterno',
          controller: _paternalSurname,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.familyName],
          errorText: errors[RegisterField.paternalSurname],
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Apellido materno · opcional',
          controller: _maternalSurname,
          textInputAction: TextInputAction.done,
          errorText: errors[RegisterField.maternalSurname],
        ),
        const SizedBox(height: 12),
        AppDateField(
          label: 'Fecha de nacimiento',
          value: _birthDate,
          firstDate: DateTime(today.year - 120),
          lastDate: DateTime(today.year, today.month, today.day),
          helperText: 'Debes tener al menos 14 años para usar Memories.',
          errorText: errors[RegisterField.birthDate],
          onChanged: (date) => setState(() => _birthDate = date),
        ),
      ],
    );
  }
}
