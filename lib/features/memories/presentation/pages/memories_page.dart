import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/layout/breakpoints.dart';
import '../../../../shared/widgets/async_view.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../domain/entities/memory.dart';
import '../providers/memory_providers.dart';
import '../widgets/memory_card.dart';

class MemoriesPage extends ConsumerStatefulWidget {
  const MemoriesPage({super.key});

  static const String ruta = '/memories';

  @override
  ConsumerState<MemoriesPage> createState() => _MemoriesPageState();
}

class _MemoriesPageState extends ConsumerState<MemoriesPage> {
  final TextEditingController _busqueda = TextEditingController();

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<PagedMemories> listado = ref.watch(memoriesControllerProvider);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _busqueda,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Buscar en mis recuerdos',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _busqueda.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _busqueda.clear();
                        ref.read(memoriesControllerProvider.notifier).buscar(null);
                        setState(() {});
                      },
                    ),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (String texto) =>
                ref.read(memoriesControllerProvider.notifier).buscar(texto),
          ),
        ),
        Expanded(
          child: AsyncView<PagedMemories>(
            valor: listado,
            alReintentar: () => ref.read(memoriesControllerProvider.notifier).refrescar(),
            datos: (PagedMemories pagina) {
              if (pagina.items.isEmpty) {
                return EmptyState(
                  icono: Icons.photo_album_outlined,
                  titulo: 'Todavia no hay recuerdos',
                  mensaje: _busqueda.text.isEmpty
                      ? 'Elige unas fotos y cuenta que paso ese dia.'
                      : 'Nada coincide con esa busqueda.',
                  accion: _busqueda.text.isNotEmpty
                      ? null
                      : FilledButton.icon(
                          onPressed: () => context.push('/memories/new'),
                          icon: const Icon(Icons.add),
                          label: const Text('Crear el primero'),
                        ),
                );
              }

              return RefreshIndicator(
                onRefresh: () =>
                    ref.read(memoriesControllerProvider.notifier).refrescar(),
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: Breakpoints.columnas(context),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: pagina.items.length + (pagina.hayMas ? 1 : 0),
                  itemBuilder: (BuildContext context, int indice) {
                    if (indice >= pagina.items.length) {
                      // Ultima celda: pide la pagina siguiente. Se hace despues
                      // del frame porque cambiar el estado de un provider
                      // mientras se construye el arbol lanza una excepcion.
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref.read(memoriesControllerProvider.notifier).cargarMas();
                      });
                      return const Center(child: CircularProgressIndicator());
                    }
                    final Memory memory = pagina.items[indice];
                    return MemoryCard(
                      memory: memory,
                      onTap: () => context.push('/memories/${memory.id}'),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
