import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_provider.dart';
import '../models/user_management_models.dart';

part 'user_management_repository.g.dart';

@riverpod
UserManagementRepository userManagementRepository(
    UserManagementRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  return UserManagementRepository(dio);
}

class UserManagementRepository {
  final Dio _dio;

  UserManagementRepository(this._dio);

  Future<List<UserManagementModel>> getUsers() async {
    try {
      final response = await _dio.get('/users');
      final List<dynamic> data = response.data;
      return data.map((json) => UserManagementModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<UserManagementModel> createUser(
      CreateUserRequestModel request) async {
    try {
      // Convert role string to enum value: Admin = 0, User = 1
      final roleValue = request.role == 'Admin' ? 0 : 1;
      
      final response = await _dio.post(
        '/users',
        data: {
          'username': request.username,
          'displayName': request.displayName,
          'password': request.password,
          'role': roleValue,
        },
      );
      return UserManagementModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserManagementModel> updateUser(
    String userId,
    UpdateUserRequestModel request,
  ) async {
    try {
      // Convert role string to enum value: Admin = 0, User = 1
      final roleValue = request.role != null 
          ? (request.role == 'Admin' ? 0 : 1)
          : null;
      
      final response = await _dio.patch(
        '/users/$userId',
        data: {
          if (request.displayName != null) 'displayName': request.displayName,
          if (request.isActive != null) 'isActive': request.isActive,
          if (roleValue != null) 'role': roleValue,
        },
      );
      return UserManagementModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _dio.delete('/users/$userId');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(
    String userId,
    ResetPasswordRequestModel request,
  ) async {
    try {
      await _dio.post(
        '/users/$userId/reset-password',
        data: {'newPassword': request.newPassword},
      );
    } catch (e) {
      rethrow;
    }
  }
}
