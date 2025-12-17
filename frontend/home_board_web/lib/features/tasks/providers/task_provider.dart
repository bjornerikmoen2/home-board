import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/task_models.dart';
import '../repositories/task_repository.dart';

part 'task_provider.g.dart';

@riverpod
class TodayTasks extends _$TodayTasks {
  @override
  Future<List<TodayTaskModel>> build() async {
    return _fetchTodayTasks();
  }

  Future<List<TodayTaskModel>> _fetchTodayTasks() async {
    final repository = ref.read(taskRepositoryProvider);
    return await repository.getTodayTasks();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchTodayTasks());
  }

  Future<void> completeTask(
    String assignmentId, {
    String? notes,
    String? photoUrl,
  }) async {
    try {
      final repository = ref.read(taskRepositoryProvider);
      await repository.completeTask(
        assignmentId,
        notes: notes,
        photoUrl: photoUrl,
      );
      // Refresh the list after completion
      await refresh();
    } catch (e) {
      rethrow;
    }
  }
}

@riverpod
class TaskDefinitions extends _$TaskDefinitions {
  @override
  Future<List<TaskDefinitionModel>> build() async {
    return _fetchTaskDefinitions();
  }

  Future<List<TaskDefinitionModel>> _fetchTaskDefinitions() async {
    final repository = ref.read(taskRepositoryProvider);
    return await repository.getAllTaskDefinitions();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchTaskDefinitions());
  }

  Future<void> createTaskDefinition(Map<String, dynamic> data) async {
    try {
      final repository = ref.read(taskRepositoryProvider);
      await repository.createTaskDefinition(data);
      // Refresh the list after creation
      await refresh();
    } catch (e) {
      rethrow;
    }
  }
}
