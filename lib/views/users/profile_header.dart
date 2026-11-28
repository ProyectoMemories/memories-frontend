import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/users_repository.dart' show Profile;
import '../../view_models/users/my_profile_view_model.dart';
import '../theme/app_colors.dart';

/// Cabecera de Perfil con quién inició sesión (users, design.md §4).
class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myProfileProvider);
    // Solo con datos ya cargados: nunca los de una cuenta que se reemplaza.
    // Al reintentar, el error sigue en el estado mientras carga.
    final content = switch (profile) {
      AsyncData(:final value?) => _ProfileData(profile: value),
      AsyncError() when !profile.isLoading => _LoadError(
        onRetry: () => ref.read(myProfileProvider.notifier).retry(),
      ),
      _ => const _Loading(),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.polaroidShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(14), child: content),
    );
  }
}

class _ProfileData extends StatelessWidget {
  const _ProfileData({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MergeSemantics(
      child: Semantics(
        label: '${profile.displayName}, @${profile.username}, ${profile.email}',
        excludeSemantics: true,
        child: Row(
          children: [
            _Avatar(
              child: Text(
                profile.initials,
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleLarge?.copyWith(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${profile.username} · ${profile.email}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mismo tamaño que la tarjeta con datos, sin animación.
class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Cargando tus datos',
      excludeSemantics: true,
      child: const Row(
        children: [
          _Avatar(color: AppColors.iconTile),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(widthFactor: 0.6, child: _Bar(height: 18)),
                SizedBox(height: 8),
                FractionallySizedBox(widthFactor: 0.9, child: _Bar(height: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'No pudimos cargar tus datos.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: onRetry,
          style: TextButton.styleFrom(minimumSize: const Size(0, 44)),
          child: const Text('Reintentar'),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.color = AppColors.avatar, this.child});

  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: child,
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.iconTile,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
