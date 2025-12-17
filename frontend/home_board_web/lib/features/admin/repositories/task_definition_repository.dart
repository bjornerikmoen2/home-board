import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_provider.dart';
import '../models/task_definition_models.dart';

part 'task_definition_repository.g.dart';

@riverpod
TaskDefinitionRepository taskDefinitionRepository(
    TaskDefinitionRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  return TaskDefinitionRepository(dio);
}

class TaskDefinitionRepository {
  final Dio _dio;

  TaskDefinitionRepository(this._dio);

  Future<List<TaskDefinitionManagementModel>> getTaskDefinitions() async {
    try {
      final response = await _dio.get('/tasks/definitions');
      final List<dynamic> data = response.data;
      return data
          .map((json) => TaskDefinitionManagementModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<TaskDefinitionManagementModel> createTaskDefinition(
      CreateTaskDefinitionRequestModel request) async {
    try {
      final response = await _dio.post(
        '/tasks/definitions',
        data: {
          'title': request.title,
          if (request.description != null) 'description': request.description,
          'defaultPoints': request.defaultPoints,
        },
      );
      return TaskDefinitionManagementModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<TaskDefinitionManagementModel> updateTaskDefinition(
    String taskId,
    UpdateTaskDefinitionRequestModel request,
  ) async {
    try {
      final response = await _dio.patch(
        '/tasks/definitions/$taskId',
        data: {
          if (request.title != null) 'title': request.title,
          if (request.description != null) 'description': request.description,
          if (request.defaultPoints != null)
            'defaultPoints': request.defaultPoints,
          if (request.isActive != null) 'isActive': request.isActive,
        },
      );
      return TaskDefinitionManagementModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTaskDefinition(String taskId) async {
    try {
      await _dio.delete('/tasks/definitions/$taskId');
    } catch (e) {
      rethrow;
    }
  }
}
