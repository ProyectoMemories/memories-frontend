import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/memory.dart';
import '../../domain/entities/memory_photo.dart';
import '../controllers/memory_form_controller.dart';
import '../providers/memory_providers.dart';

/// Crear o editar un recuerdo.
///
/// Al crear se eligen fotografias; al editar solo se cambia el texto y la fecha
/// (las fotografias se gestionan desde el detalle, que es donde se ven).
class MemoryFormPage extends ConsumerStatefulWidget {
  const MemoryFormPage({this.memoryId, super.key});

  final String? memoryId;

  bool get esEdicion => memoryId != null;

  @override
  ConsumerState<MemoryFormPage> createState() => _MemoryFormPageState();
}

class _MemoryFormPageState extends ConsumerState<MemoryFormPage> {
  final GlobalKey<FormState> _formulario = GlobalKey<FormState>();
  final TextEditingController _titulo = TextEditingController();
  final TextEditingController _descripcion = TextEditingController();
  DateTime _fecha = Fechas.soloDia(DateTime.now());
  bool _cargado = false;

  @override
  void initState() {
    super.initState();
    if (!widget.esEdicion) {
      // El formulario empieza limpio en cada creacion.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(memoryFormControllerProvider.notifier).reiniciar();
      });
    }
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  void _precargar(Memory memory) {
    if (_cargado) {
      return;
    }
    _titulo.text = memory.title;
    _descripcion.text = memory.description ?? '';
    _fecha = memory.momentDate;
    _cargado = true;
  }

  Future<void> _elegirFecha() async {
    final DateTime? elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(1900),
      // El dominio no admite recuerdos del futuro.
      lastDate: Fechas.soloDia(DateTime.now()),
      helpText: 'Cuando ocurrio',
    );
    if (elegida != null) {
      setState(() => _fecha = elegida);
    }
  }

  Future<void> _guardar() async {
    if (!_formulario.currentState!.validate()) {
      return;
    }
    final Memory? guardado =
        await ref.read(memoryFormControllerProvider.notifier).guardar(
              titulo: _titulo.text.trim(),
              fecha: _fecha,
              descripcion: _descripcion.text.trim(),
              memoryIdAEditar: widget.memoryId,
            );

    if (!mounted) {
      return;
    }
    if (guardado == null) {
      final String? error = ref.read(memoryFormControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'No se pudo guardar.')),
      );
      return;
    }
    if (widget.esEdicion) {
      ref.invalidate(memoryDetailProvider(widget.memoryId!));
    }
    context.go('/memories');
  }

  @override
  Widget build(BuildContext context) {
    final MemoryFormState formulario = ref.watch(memoryFormControllerProvider);

    if (widget.esEdicion) {
      final AsyncValue<Memory> detalle = ref.watch(memoryDetailProvider(widget.memoryId!));
      detalle.whenData(_precargar);
      if (detalle.isLoading && !_cargado) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.esEdicion ? 'Editar recuerdo' : 'Nuevo recuerdo'),
      ),
      body: SafeArea(
        child: Form(
          key: _formulario,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: <Widget>[
              if (!widget.esEdicion) ...<Widget>[
                _Fotografias(estado: formulario),
                const SizedBox(height: 24),
              ],
              AppTextField(
                controller: _titulo,
                etiqueta: 'Titulo',
                maximoCaracteres: Validaciones.maximoTitulo,
                validador: Validaciones.titulo,
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: const Text('Cuando ocurrio'),
                subtitle: Text(Fechas.largo(_fecha)),
                trailing: TextButton(
                  onPressed: _elegirFecha,
                  child: const Text('Cambiar'),
                ),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _descripcion,
                etiqueta: 'Que paso ese dia',
                lineas: 5,
                maximoCaracteres: Validaciones.maximoDescripcion,
                validador: Validaciones.descripcion,
                textoAyuda: 'Opcional, pero es lo que la galeria no guarda.',
              ),
              const SizedBox(height: 24),
              AppButton(
                texto: widget.esEdicion ? 'Guardar cambios' : 'Guardar recuerdo',
                cargando: formulario.guardando,
                onPressed:
                    widget.esEdicion || formulario.puedeGuardar ? _guardar : null,
              ),
              if (!widget.esEdicion && formulario.fotos.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Anade al menos una fotografia para poder guardar.',
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Fotografias extends ConsumerWidget {
  const _Fotografias({required this.estado});

  final MemoryFormState estado;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Fotografias', style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              onPressed: estado.subiendo
                  ? null
                  : () => ref
                      .read(memoryFormControllerProvider.notifier)
                      .elegirYSubirFotos(),
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Anadir'),
            ),
          ],
        ),
        if (estado.subiendo) const LinearProgressIndicator(),
        if (estado.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              estado.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: 12),
        if (estado.fotos.isEmpty)
          const Text('Todavia no has elegido ninguna.')
        else
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: estado.fotos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (BuildContext context, int indice) {
                final MemoryPhoto foto = estado.fotos[indice];
                return Stack(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        foto.url,
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (BuildContext context, Object error, StackTrace? _) =>
                                const SizedBox(
                          width: 110,
                          height: 110,
                          child: Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.white),
                        onPressed: () => ref
                            .read(memoryFormControllerProvider.notifier)
                            .quitarFoto(foto.id),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}
