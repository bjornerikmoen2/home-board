import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_provider.dart';
import '../models/task_models.dart';

part 'task_repository.g.dart';

@riverpod
TaskRepository taskRepository(TaskRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  return TaskRepository(dio);
}

class TaskRepository {
  final Dio _dio;

  TaskRepository(this._dio);

  Future<List<TodayTaskModel>> getTodayTasks() async {
    try {
      final response = await _dio.get('/me/today');
      final List<dynamic> data = response.data;
      return data.map((json) => TodayTaskModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> completeTask(
    int assignmentId, {
    String? notes,
    String? photoUrl,
  }) async {
    try {
      await _dio.post(
        '/tasks/$assignmentId/complete',
        data: {
          if (notes != null) 'notes': notes,
          if (photoUrl != null) 'photoUrl': photoUrl,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TaskDefinitionModel>> getAllTaskDefinitions() async {
    try {
      final response = await _dio.get('/tasks');
      final List<dynamic> data = response.data;
      return data.map((json) => TaskDefinitionModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<TaskDefinitionModel> createTaskDefinition(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post('/tasks', data: data);
      return TaskDefinitionModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
