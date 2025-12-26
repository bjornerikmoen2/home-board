import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_provider.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/no_password_user_model.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(ref.watch(dioProvider));
}

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
      // Ignore errors on logout
    }
  }

  Future<List<NoPasswordUserModel>> getNoPasswordUsers() async {
    try {
      final response = await _dio.get('/auth/no-password-users');
      final List<dynamic> data = response.data;
      return data.map((json) => NoPasswordUserModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
