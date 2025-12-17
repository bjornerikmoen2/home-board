import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/app_constants.dart';
import '../../features/auth/models/user_model.dart';

part 'storage_service.g.dart';

@riverpod
StorageService storageService(StorageServiceRef ref) {
  return StorageService();
}

class StorageService {
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // Access Token
  Future<void> saveAccessToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.accessTokenKey, token);
  }

  Future<String?> getAccessToken() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.accessTokenKey);
  }

  // Refresh Token
  Future<void> saveRefreshToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.refreshTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.refreshTokenKey);
  }

  // User
  Future<void> saveUser(UserModel user) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    final prefs = await _prefs;
    final userJson = prefs.getString(AppConstants.userKey);
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson));
  }

  // Clear all
  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
