import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../view_models/auth/login_view_model.dart';
import '../theme/app_colors.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_password_field.dart';
import '../widgets/app_text_field.dart';

/// Iniciar sesión (HU-01), pantalla "Iniciar sesión" del mockup.
///
/// "¿Olvidaste tu contraseña?" y "Crear cuenta" llegan en F7 y F6, con sus
/// pantallas (tasks.md).
class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _identifier = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    ref
        .read(loginViewModelProvider.notifier)
        .submit(identifier: _identifier.text, password: _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginViewModelProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 26),
            child: ConstrainedBox(
              // Un solo diseño: en pantallas anchas, una columna centrada.
              constraints: const BoxConstraints(maxWidth: 420),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _PolaroidHeader(),
                    Text(
                      'Memories',
                      style: textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tus fotos, con la historia que las hizo importantes.',
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      label: 'Correo o nombre de usuario',
                      controller: _identifier,
                      hint: 'tu@correo.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [
                        AutofillHints.username,
                        AutofillHints.email,
                      ],
                      errorText: state.identifierError,
                      enabled: !state.isSubmitting,
                    ),
                    const SizedBox(height: 14),
                    AppPasswordField(
                      label: 'Contraseña',
                      controller: _password,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      errorText: state.passwordError,
                      enabled: !state.isSubmitting,
                    ),
                    if (state.errorMessage case final message?) ...[
                      const SizedBox(height: 14),
                      _ErrorText(
                        message,
                        announcement: state.errorAnnouncement ?? message,
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Siempre responde: si falta algo, el campo lo dice.
                    PrimaryButton(
                      label: 'Entrar',
                      onPressed: _submit,
                      isLoading: state.isSubmitting,
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

/// Error del envío. `liveRegion` hace que el lector de pantalla lo anuncie
/// apenas aparece; anuncia [announcement] y no el texto visible, que en la
/// cuenta regresiva cambia cada segundo.
class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message, {required this.announcement});

  final String message;
  final String announcement;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: announcement,
      child: ExcludeSemantics(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: AppColors.danger),
        ),
      ),
    );
  }
}

/// Las tres polaroids de la cabecera del mockup. Es decoración: el lector de
/// pantalla la salta.
class _PolaroidHeader extends StatelessWidget {
  const _PolaroidHeader();

  @override
  Widget build(BuildContext context) {
    // Posiciones del mockup (390 px de ancho), recortadas a lo que ocupan
    // las fotos. Se achica en pantallas angostas.
    return ExcludeSemantics(
      child: SizedBox(
        height: 250,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: 330,
            height: 250,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _Polaroid(
                  left: 0,
                  top: 30,
                  photo: const Size(134, 130),
                  degrees: -7,
                  color: AppColors.polaroidPhotos[0],
                ),
                _Polaroid(
                  left: 166,
                  top: 14,
                  photo: const Size(134, 130),
                  degrees: 5,
                  color: AppColors.polaroidPhotos[1],
                ),
                _Polaroid(
                  left: 84,
                  top: 66,
                  photo: const Size(144, 140),
                  degrees: -1,
                  color: AppColors.polaroidPhotos[2],
                  caption: 'marzo, 2026',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Polaroid extends StatelessWidget {
  const _Polaroid({
    required this.left,
    required this.top,
    required this.photo,
    required this.degrees,
    required this.color,
    this.caption,
  });

  final double left;
  final double top;
  final Size photo;
  final double degrees;
  final Color color;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: degrees * math.pi / 180,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [
              BoxShadow(
                color: AppColors.polaroidShadow,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: photo.width,
                height: photo.height,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(
                height: caption == null ? 28 : 32,
                child: caption == null
                    ? null
                    : Center(
                        child: Text(
                          caption!,
                          style: textTheme.bodyMedium?.copyWith(
                            fontFamily: AppFonts.titles,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: AppColors.label,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
