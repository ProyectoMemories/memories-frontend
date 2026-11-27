import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Ancho de la columna de auth en pantallas anchas (design §3).
const _maxContentWidth = 420.0;

/// Barra superior del registro: flecha atrás, título al centro.
class AuthTopBar extends StatelessWidget {
  const AuthTopBar({super.key, required this.title, required this.onBack});

  final String title;

  /// null mientras algo se envía: volver dejaría el envío sin respuesta.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Volver',
            iconSize: 22,
            constraints: const BoxConstraints.tightFor(width: 46, height: 46),
            icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
            onPressed: onBack,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(fontSize: 15, color: AppColors.textPrimary),
            ),
          ),
          // Mismo ancho que la flecha, para que el título quede centrado.
          const SizedBox(width: 46),
        ],
      ),
    );
  }
}

/// Barra de progreso de pasos con "PASO N DE M" debajo.
class StepProgress extends StatelessWidget {
  const StepProgress({super.key, required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final label = 'Paso $current de $total';
    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  for (var step = 1; step <= total; step++) ...[
                    if (step > 1) const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: step <= current
                              ? AppColors.primary
                              : AppColors.progressTrack,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Formulario de varios campos (Registro 1 y 2): barra superior, contenido
/// con scroll y el botón principal fijo abajo, como en el mockup.
class AuthFormScaffold extends StatelessWidget {
  const AuthFormScaffold({
    super.key,
    required this.onBack,
    required this.topBar,
    this.progress,
    required this.title,
    required this.children,
    required this.footer,
  });

  /// Lo que hace el botón atrás de Android (ver [_SystemBack]).
  final VoidCallback? onBack;
  final Widget topBar;
  final Widget? progress;
  final String title;
  final List<Widget> children;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return _SystemBack(
      onBack: onBack,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _Centered(child: Column(children: [topBar, ?progress])),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: _Centered(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        ...children,
                      ],
                    ),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
                    child: _Centered(child: footer),
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

/// Pantalla de aviso (Revisa tu correo, Menor de 14, Correo verificado):
/// ícono, título, texto y botones al fondo.
class AuthMessageScaffold extends StatelessWidget {
  const AuthMessageScaffold({
    super.key,
    required this.onBack,
    this.topBar,
    required this.icon,
    required this.title,
    required this.body,
    this.extra,
    this.actions = const [],
  });

  /// Lo que hace el botón atrás de Android (ver [_SystemBack]).
  final VoidCallback? onBack;
  final Widget? topBar;
  final IconData icon;
  final String title;

  /// Texto bajo el título; puede traer partes en negrita.
  final Widget body;

  /// Algo más bajo el texto, como el campo de correo para reenviar.
  final Widget? extra;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    // Con barra superior el mockup deja menos espacio arriba.
    final top = topBar == null ? 64.0 : 40.0;
    return _SystemBack(
      onBack: onBack,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              ?topBar,
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // Llena la pantalla para dejar los botones al fondo, y hace
                    // scroll si no entran.
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(24, top, 24, 28),
                        child: _Centered(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(child: IconTile(icon: icon)),
                              const SizedBox(height: 18),
                              Semantics(
                                header: true,
                                child: Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall,
                                ),
                              ),
                              const SizedBox(height: 18),
                              DefaultTextStyle.merge(
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                                child: body,
                              ),
                              if (extra case final extra?) ...[
                                const SizedBox(height: 18),
                                extra,
                              ],
                              const Spacer(),
                              for (final action in actions) ...[
                                const SizedBox(height: 18),
                                action,
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Las pantallas de auth se abren con `go`, así que la pila tiene una sola
/// página: sin esto, el botón atrás de Android cerraría la app. Hace lo mismo
/// que la flecha de la pantalla; con [onBack] null (enviando) no hace nada.
class _SystemBack extends StatelessWidget {
  const _SystemBack({required this.onBack, required this.child});

  final VoidCallback? onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onBack?.call();
      },
      child: child,
    );
  }
}

/// Cuadro del ícono de los avisos (correo, candado). Es decoración.
class IconTile extends StatelessWidget {
  const IconTile({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.iconTile,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Icon(icon, size: 38, color: AppColors.primary),
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxContentWidth),
        child: child,
      ),
    );
  }
}
