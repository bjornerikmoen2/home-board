import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user_management_models.dart';
import '../repositories/user_management_repository.dart';

part 'user_management_provider.g.dart';

@riverpod
class UserManagement extends _$UserManagement {
  @override
  Future<List<UserManagementModel>> build() async {
    return _fetchUsers();
  }

  Future<List<UserManagementModel>> _fetchUsers() async {
    final repository = ref.read(userManagementRepositoryProvider);
    return await repository.getUsers();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchUsers());
  }

  Future<void> createUser(CreateUserRequestModel request) async {
    try {
      final repository = ref.read(userManagementRepositoryProvider);
      await repository.createUser(request);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUser(
    String userId,
    UpdateUserRequestModel request,
  ) async {
    try {
      final repository = ref.read(userManagementRepositoryProvider);
      await repository.updateUser(userId, request);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final repository = ref.read(userManagementRepositoryProvider);
      await repository.deleteUser(userId);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(
    String userId,
    ResetPasswordRequestModel request,
  ) async {
    try {
      final repository = ref.read(userManagementRepositoryProvider);
      await repository.resetPassword(userId, request);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPoints(String userId) async {
    try {
      final repository = ref.read(userManagementRepositoryProvider);
      await repository.resetPoints(userId);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }
}
