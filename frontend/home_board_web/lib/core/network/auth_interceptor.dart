import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/storage_service.dart';
import '../../features/auth/models/auth_response.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Adds the access token to every request. When it has expired (401), gets a new one with the
/// refresh token and repeats the request once; only when that fails is the user logged out.
class AuthInterceptor extends Interceptor {
  final Ref ref;
  final Dio dio;

  /// The refresh in progress, shared by the requests that fail at the same time.
  Future<bool>? _refreshing;

  static const _retried = 'authRetried';

  AuthInterceptor(this.ref, this.dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get token from storage
    final token = await ref.read(storageServiceProvider).getAccessToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    // Login, refresh and logout answer 401 for reasons a refresh can't fix.
    if (err.response?.statusCode != 401 || request.path.startsWith('/auth/')) {
      return handler.next(err);
    }

    if (request.extra[_retried] != true && await _refresh(request)) {
      request.extra[_retried] = true;
      try {
        return handler.resolve(await dio.fetch(request));
      } on DioException catch (retryError) {
        return handler.next(retryError);
      }
    }

    // Logout user
    ref.read(authNotifierProvider.notifier).logout();
    return handler.next(err);
  }

  Future<bool> _refresh(RequestOptions failed) {
    return _refreshing ??= _swapTokens(failed).whenComplete(() => _refreshing = null);
  }

  Future<bool> _swapTokens(RequestOptions failed) async {
    final storage = ref.read(storageServiceProvider);
    // Another request, or another browser tab, already got a new access token: just retry.
    final current = await storage.getAccessToken();
    if (current != null && failed.headers['Authorization'] != 'Bearer $current') {
      return true;
    }

    final refreshToken = await storage.getRefreshToken();
    if (refreshToken == null) {
      return false;
    }
    try {
      final response = await dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
      final tokens = AuthResponse.fromJson(response.data);
      await storage.saveAccessToken(tokens.accessToken);
      await storage.saveRefreshToken(tokens.refreshToken);
      await storage.saveUser(tokens.user);
      return true;
    } on DioException {
      // Each refresh token works once: another tab may have just used it and stored the new one.
      return await storage.getRefreshToken() != refreshToken;
    }
  }
}
