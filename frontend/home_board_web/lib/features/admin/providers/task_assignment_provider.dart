import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/task_assignment_models.dart';
import '../repositories/task_assignment_repository.dart';

part 'task_assignment_provider.g.dart';

@riverpod
class TaskAssignmentManagement extends _$TaskAssignmentManagement {
  @override
  Future<List<TaskAssignmentModel>> build() async {
    return _fetchTaskAssignments();
  }

  Future<List<TaskAssignmentModel>> _fetchTaskAssignments() async {
    final repository = ref.read(taskAssignmentRepositoryProvider);
    return await repository.getTaskAssignments();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchTaskAssignments());
  }

  Future<void> createTaskAssignment(
      CreateTaskAssignmentRequest request) async {
    try {
      final repository = ref.read(taskAssignmentRepositoryProvider);
      await repository.createTaskAssignment(request);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTaskAssignment(
    String assignmentId,
    UpdateTaskAssignmentRequest request,
  ) async {
    try {
      final repository = ref.read(taskAssignmentRepositoryProvider);
      await repository.updateTaskAssignment(assignmentId, request);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTaskAssignment(String assignmentId) async {
    try {
      final repository = ref.read(taskAssignmentRepositoryProvider);
      await repository.deleteTaskAssignment(assignmentId);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }
}
