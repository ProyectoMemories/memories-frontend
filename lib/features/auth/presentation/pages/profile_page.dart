import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/async_view.dart';
import '../../domain/entities/app_user.dart';
import '../providers/auth_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  static const String ruta = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppUser?> sesion = ref.watch(authControllerProvider);

    return AsyncView<AppUser?>(
      valor: sesion,
      datos: (AppUser? usuario) {
        if (usuario == null) {
          return const Center(child: Text('No hay sesion abierta.'));
        }
        return ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            Center(
              child: CircleAvatar(
                radius: 40,
                child: Text(
                  usuario.iniciales,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                usuario.displayName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Center(child: Text(usuario.email)),
            const SizedBox(height: 32),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('Rol'),
              subtitle: Text(usuario.esSuperusuario ? 'Superusuario' : 'Usuario'),
            ),
            const Divider(),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => ref.read(authControllerProvider.notifier).cerrarSesion(),
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesion'),
            ),
          ],
        );
      },
    );
  }
}
