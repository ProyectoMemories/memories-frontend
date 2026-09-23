import 'memory.dart';

/// Por que la aplicacion propone estos recuerdos.
enum MotivoRevivir {
  enEsteDia,
  alAzar,
  ninguno;

  static MotivoRevivir desdeApi(String valor) {
    switch (valor) {
      case 'on_this_day':
        return MotivoRevivir.enEsteDia;
      case 'random':
        return MotivoRevivir.alAzar;
      default:
        return MotivoRevivir.ninguno;
    }
  }

  String get titulo {
    switch (this) {
      case MotivoRevivir.enEsteDia:
        return 'Un dia como hoy';
      case MotivoRevivir.alAzar:
        return 'Para volver a verlos';
      case MotivoRevivir.ninguno:
        return 'Todavia no hay nada que revivir';
    }
  }
}

class ReviveResult {
  const ReviveResult({required this.motivo, required this.memories});

  final MotivoRevivir motivo;
  final List<Memory> memories;

  bool get hayAlgo => memories.isNotEmpty;
}
