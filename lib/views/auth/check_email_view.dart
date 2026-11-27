import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../view_models/auth/check_email_view_model.dart';
import '../app_router.dart';
import '../theme/app_colors.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_toast.dart';
import '../widgets/auth_layouts.dart';
import '../widgets/form_error_text.dart';

/// Revisa tu correo (HU-03): pantalla "Verifica tu correo" del mockup.
///
/// Si no se sabe el correo (se entró con nombre de usuario o se recargó la
/// página), lo pide para poder reenviar el enlace.
class CheckEmailView extends ConsumerStatefulWidget {
  const CheckEmailView({super.key, this.email});

  final String? email;

  @override
  ConsumerState<CheckEmailView> createState() => _CheckEmailViewState();
}

class _CheckEmailViewState extends ConsumerState<CheckEmailView> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _resend() async {
    final resent = await ref
        .read(checkEmailViewModelProvider.notifier)
        .resend(widget.email ?? _email.text);
    if (resent && mounted) showAppToast(context, 'Correo reenviado');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkEmailViewModelProvider);
    final email = widget.email;

    return AuthMessageScaffold(
      icon: Icons.mail_outline,
      title: 'Revisa tu correo',
      body: email == null
          ? const Text(
              'Te enviamos un enlace a tu correo. Ábrelo para activar tu '
              'cuenta. El enlace vence en 24 horas.',
            )
          : Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Enviamos un enlace a '),
                  TextSpan(
                    text: email,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(
                    text:
                        '. Ábrelo para activar tu cuenta. El enlace vence en '
                        '24 horas.',
                  ),
                ],
              ),
            ),
      extra: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (email == null)
            AppTextField(
              label: 'Correo',
              controller: _email,
              hint: 'tu@correo.com',
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              helperText: 'Para reenviarte el enlace.',
              errorText: state.emailError,
              enabled: !state.isResending,
            ),
          if (state.errorMessage case final message?) ...[
            const SizedBox(height: 14),
            FormErrorText(message),
          ],
        ],
      ),
      actions: [
        PrimaryButton(
          label: 'Ya lo verifiqué',
          onPressed: () => context.go(AppRoutes.login),
        ),
        SecondaryButton(
          label: state.isResending ? 'Reenviando…' : 'Reenviar correo',
          onPressed: state.isResending ? null : _resend,
        ),
      ],
    );
  }
}
