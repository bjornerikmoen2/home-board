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
      
      final formData = FormData.fromMap({
        'username': request.username,
        'displayName': request.displayName,
        'role': roleValue,
        'noPasswordRequired': request.noPasswordRequired,
        'preferredLanguage': request.preferredLanguage,
      });
      
      // Only include password if it's provided
      if (request.password != null && request.password!.isNotEmpty) {
        formData.fields.add(MapEntry('password', request.password!));
      }
      
      if (request.profileImage != null && request.profileImageName != null) {
        formData.files.add(MapEntry(
          'ProfileImage',
          MultipartFile.fromBytes(
            request.profileImage!,
            filename: request.profileImageName!,
          ),
        ));
      }
      
      final response = await _dio.post(
        '/users',
        data: formData,
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
      
      final formData = FormData();
      
      if (request.displayName != null) {
        formData.fields.add(MapEntry('displayName', request.displayName!));
      }
      if (request.isActive != null) {
        formData.fields.add(MapEntry('isActive', request.isActive.toString()));
      }
      if (roleValue != null) {
        formData.fields.add(MapEntry('role', roleValue.toString()));
      }
      if (request.noPasswordRequired != null) {
        formData.fields.add(MapEntry('noPasswordRequired', request.noPasswordRequired.toString()));
      }
      if (request.preferredLanguage != null) {
        formData.fields.add(MapEntry('preferredLanguage', request.preferredLanguage!));
      }
      if (request.removeProfileImage == true) {
        formData.fields.add(const MapEntry('removeProfileImage', 'true'));
      }
      
      if (request.profileImage != null && request.profileImageName != null) {
        formData.files.add(MapEntry(
          'ProfileImage',
          MultipartFile.fromBytes(
            request.profileImage!,
            filename: request.profileImageName!,
          ),
        ));
      }
      
      final response = await _dio.patch(
        '/users/$userId',
        data: formData,
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

  Future<void> resetPoints(String userId) async {
    try {
      await _dio.post('/users/$userId/reset-points');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> awardBonusPoints(
    String userId,
    BonusPointsRequestModel request,
  ) async {
    try {
      await _dio.post(
        '/users/$userId/bonus-points',
        data: request.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }
}
