import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_provider.dart';
import '../models/task_assignment_models.dart';

part 'task_assignment_repository.g.dart';

@riverpod
TaskAssignmentRepository taskAssignmentRepository(
    TaskAssignmentRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  return TaskAssignmentRepository(dio);
}

class TaskAssignmentRepository {
  final Dio _dio;

  TaskAssignmentRepository(this._dio);

  Future<List<TaskAssignmentModel>> getTaskAssignments() async {
    try {
      final response = await _dio.get('/tasks/assignments');
      final List<dynamic> data = response.data;
      return data.map((json) => TaskAssignmentModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<TaskAssignmentModel> createTaskAssignment(
      CreateTaskAssignmentRequest request) async {
    try {
      final response = await _dio.post(
        '/tasks/assignments',
        data: {
          'taskDefinitionId': request.taskDefinitionId,
          'assignedToUserId': request.assignedToUserId,
          'assignedToGroup': request.assignedToGroup,
          'scheduleType': request.scheduleType,
          'daysOfWeek': request.daysOfWeek,
          if (request.startDate != null) 'startDate': request.startDate,
          if (request.endDate != null) 'endDate': request.endDate,
          if (request.dueTime != null) 'dueTime': request.dueTime,
        },
      );
      return TaskAssignmentModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<TaskAssignmentModel> updateTaskAssignment(
    String assignmentId,
    UpdateTaskAssignmentRequest request,
  ) async {
    try {
      final response = await _dio.patch(
        '/tasks/assignments/$assignmentId',
        data: {
          if (request.taskDefinitionId != null) 'taskDefinitionId': request.taskDefinitionId,
          if (request.assignedToUserId != null) 'assignedToUserId': request.assignedToUserId,
          if (request.assignedToGroup != null) 'assignedToGroup': request.assignedToGroup,
          if (request.scheduleType != null) 'scheduleType': request.scheduleType,
          if (request.daysOfWeek != null) 'daysOfWeek': request.daysOfWeek,
          'startDate': request.startDate,  // Include even if null to allow clearing
          'endDate': request.endDate,      // Include even if null to allow clearing
          'dueTime': request.dueTime,      // Include even if null to allow clearing
          if (request.isActive != null) 'isActive': request.isActive,
        },
      );
      return TaskAssignmentModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTaskAssignment(String assignmentId) async {
    try {
      await _dio.delete('/tasks/assignments/$assignmentId');
    } catch (e) {
      rethrow;
    }
  }
}
