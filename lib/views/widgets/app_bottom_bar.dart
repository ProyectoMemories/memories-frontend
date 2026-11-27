import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Pestañas de la barra inferior del mockup.
enum AppTab { home, profile }

/// Barra inferior de "Inicio: álbumes" y "Perfil": Inicio, Álbum (botón
/// central) y Perfil.
class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    super.key,
    required this.current,
    required this.onSelect,
    this.onCreateAlbum,
  });

  final AppTab current;
  final ValueChanged<AppTab> onSelect;

  /// Null mientras no exista el módulo de álbumes: el botón se ve pero no
  /// responde.
  final VoidCallback? onCreateAlbum;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          // 86 px, como en el mockup: cabe el botón redondo con su texto.
          height: 86,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _TabButton(
                  label: 'Inicio',
                  icon: Icons.home_outlined,
                  selected: current == AppTab.home,
                  onTap: () => onSelect(AppTab.home),
                ),
              ),
              Expanded(child: _CreateAlbumButton(onPressed: onCreateAlbum)),
              Expanded(
                child: _TabButton(
                  label: 'Perfil',
                  icon: Icons.person_outline,
                  selected: current == AppTab.profile,
                  onTap: () => onSelect(AppTab.profile),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: color, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 3),
              // El punto marca la pestaña actual, como en el mockup.
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.primary : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateAlbumButton extends StatelessWidget {
  const _CreateAlbumButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Sube por encima de la barra, como el botón redondo del mockup.
        Transform.translate(
          offset: const Offset(0, -26),
          child: Semantics(
            label: enabled
                ? 'Crear álbum'
                : 'Crear álbum, todavía no disponible',
            button: true,
            enabled: enabled,
            excludeSemantics: true,
            child: Material(
              color: AppColors.primary,
              shape: const CircleBorder(
                side: BorderSide(color: AppColors.background, width: 5),
              ),
              elevation: 4,
              shadowColor: AppColors.primary,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onPressed,
                child: SizedBox.square(
                  dimension: 64,
                  child: Icon(
                    Icons.add,
                    size: 30,
                    color: enabled
                        ? AppColors.onPrimary
                        : AppColors.onPrimary.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -22),
          child: ExcludeSemantics(
            child: Text(
              'Álbum',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
