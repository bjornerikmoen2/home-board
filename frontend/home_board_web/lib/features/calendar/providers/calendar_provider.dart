import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../models/calendar_models.dart';
import '../repositories/calendar_repository.dart';

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CalendarRepository(dio);
});

class CalendarNotifier extends StateNotifier<AsyncValue<List<CalendarTaskModel>>> {
  final CalendarRepository _repository;
  DateTime _currentStartDate;
  DateTime _currentEndDate;

  CalendarNotifier(this._repository)
      : _currentStartDate = DateTime.now(),
        _currentEndDate = DateTime.now().add(const Duration(days: 30)),
        super(const AsyncValue.loading()) {
    loadTasks();
  }

  Future<void> loadTasks([DateTime? startDate, DateTime? endDate]) async {
    if (startDate != null) _currentStartDate = startDate;
    if (endDate != null) _currentEndDate = endDate;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.getCalendarTasks(_currentStartDate, _currentEndDate),
    );
  }

  Future<void> refresh() async {
    await loadTasks();
  }

  void updateDateRange(DateTime startDate, DateTime endDate) {
    loadTasks(startDate, endDate);
  }
}

final calendarProvider =
    StateNotifierProvider<CalendarNotifier, AsyncValue<List<CalendarTaskModel>>>(
  (ref) {
    final repository = ref.watch(calendarRepositoryProvider);
    return CalendarNotifier(repository);
  },
);
