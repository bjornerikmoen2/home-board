import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/task_definition_models.dart';
import '../repositories/task_definition_repository.dart';

part 'task_definition_provider.g.dart';

@riverpod
class TaskDefinitionManagement extends _$TaskDefinitionManagement {
  @override
  Future<List<TaskDefinitionManagementModel>> build() async {
    return _fetchTaskDefinitions();
  }

  Future<List<TaskDefinitionManagementModel>> _fetchTaskDefinitions() async {
    final repository = ref.read(taskDefinitionRepositoryProvider);
    return await repository.getTaskDefinitions();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchTaskDefinitions());
  }

  Future<void> createTaskDefinition(
      CreateTaskDefinitionRequestModel request) async {
    try {
      final repository = ref.read(taskDefinitionRepositoryProvider);
      await repository.createTaskDefinition(request);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTaskDefinition(
    String taskId,
    UpdateTaskDefinitionRequestModel request,
  ) async {
    try {
      final repository = ref.read(taskDefinitionRepositoryProvider);
      await repository.updateTaskDefinition(taskId, request);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTaskDefinition(String taskId) async {
    try {
      final repository = ref.read(taskDefinitionRepositoryProvider);
      await repository.deleteTaskDefinition(taskId);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }
}
