import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user_model.dart';
import '../models/login_request.dart';
import '../repositories/auth_repository.dart';
import '../../../core/storage/storage_service.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<UserModel?> build() async {
    // Check if user is already logged in
    final user = await ref.read(storageServiceProvider).getUser();
    return user;
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final request = LoginRequest(username: username, password: password);
      final response = await ref.read(authRepositoryProvider).login(request);

      // Save tokens and user
      final storage = ref.read(storageServiceProvider);
      await storage.saveAccessToken(response.accessToken);
      await storage.saveRefreshToken(response.refreshToken);
      await storage.saveUser(response.user);

      return response.user;
    });
  }

  Future<void> logout() async {
    // Call logout endpoint
    await ref.read(authRepositoryProvider).logout();

    // Clear storage
    await ref.read(storageServiceProvider).clearAll();

    // Update state
    state = const AsyncValue.data(null);
  }

  bool get isAuthenticated => state.value != null;
  bool get isAdmin => state.value?.role == 'Admin';
  bool get isUser => state.value?.role == 'User';
}
