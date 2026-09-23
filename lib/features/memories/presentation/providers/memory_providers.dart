import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/memory_remote_data_source.dart';
import '../../data/repositories/memory_repository_impl.dart';
import '../../domain/entities/calendar_day.dart';
import '../../domain/entities/memory.dart';
import '../../domain/entities/revive_result.dart';
import '../../domain/repositories/memory_repository.dart';
import '../controllers/memories_controller.dart';
import '../controllers/memory_form_controller.dart';

final Provider<MemoryRepository> memoryRepositoryProvider =
    Provider<MemoryRepository>((Ref ref) {
  return MemoryRepositoryImpl(MemoryRemoteDataSource(ref.watch(dioProvider)));
});

/// Listado de recuerdos con su busqueda.
final AsyncNotifierProvider<MemoriesController, PagedMemories> memoriesControllerProvider =
    AsyncNotifierProvider<MemoriesController, PagedMemories>(MemoriesController.new);

/// Detalle de un recuerdo concreto.
final FutureProviderFamily<Memory, String> memoryDetailProvider =
    FutureProvider.family<Memory, String>((Ref ref, String id) {
  return ref.watch(memoryRepositoryProvider).obtener(id);
});

/// Recuerdos de un dia concreto, para el detalle del calendario.
final FutureProviderFamily<List<Memory>, DateTime> recuerdosDelDiaProvider =
    FutureProvider.family<List<Memory>, DateTime>((Ref ref, DateTime dia) async {
  final PagedMemories pagina = await ref.watch(memoryRepositoryProvider).listar(
        desde: dia,
        hasta: dia,
        tamano: 50,
      );
  return pagina.items;
});

/// Mes que se esta viendo en el calendario.
final StateProvider<DateTime> mesDelCalendarioProvider = StateProvider<DateTime>((Ref ref) {
  final DateTime ahora = DateTime.now();
  return DateTime(ahora.year, ahora.month);
});

final FutureProvider<List<CalendarDay>> calendarioProvider =
    FutureProvider<List<CalendarDay>>((Ref ref) {
  final DateTime mes = ref.watch(mesDelCalendarioProvider);
  return ref.watch(memoryRepositoryProvider).calendario(ano: mes.year, mes: mes.month);
});

final FutureProvider<ReviveResult> revivirProvider = FutureProvider<ReviveResult>((Ref ref) {
  return ref.watch(memoryRepositoryProvider).revivir();
});

/// Estado del formulario de creacion y edicion.
final NotifierProvider<MemoryFormController, MemoryFormState> memoryFormControllerProvider =
    NotifierProvider<MemoryFormController, MemoryFormState>(MemoryFormController.new);
