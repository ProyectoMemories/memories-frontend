import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pinta los tres estados de una carga asincrona en un solo sitio.
///
/// Sin esto, cada pantalla repite su propio `if (cargando) ... else if (error)`,
/// y cada una acaba mostrando el error de una forma distinta.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    required this.valor,
    required this.datos,
    this.alReintentar,
    super.key,
  });

  final AsyncValue<T> valor;
  final Widget Function(T datos) datos;
  final VoidCallback? alReintentar;

  @override
  Widget build(BuildContext context) {
    return valor.when(
      data: datos,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace _) => _Error(
        mensaje: _mensajeDe(error),
        alReintentar: alReintentar,
      ),
    );
  }

  static String _mensajeDe(Object error) {
    final String texto = error.toString();
    // ApiException ya trae un mensaje pensado para leerse.
    final int separador = texto.indexOf('): ');
    return separador == -1 ? texto : texto.substring(separador + 3);
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.mensaje, this.alReintentar});

  final String mensaje;
  final VoidCallback? alReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: 40,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(mensaje, textAlign: TextAlign.center),
            if (alReintentar != null) ...<Widget>[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: alReintentar,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
