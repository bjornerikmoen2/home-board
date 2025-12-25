import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_provider.dart';

/// Manages the app's theme mode (light/dark)
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Ref ref;
  
  ThemeModeNotifier(this.ref) : super(ThemeMode.light) {
    _loadThemeMode();
  }

  static const String _themeModeKey = 'theme_mode';

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeModeKey);
    if (isDark != null) {
      state = isDark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  Future<void> setThemeMode(bool isDark, {bool saveToBackend = true}) async {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeModeKey, isDark);
    
    // Save to backend if user is logged in
    if (saveToBackend) {
      try {
        final dio = ref.read(dioProvider);
        await dio.patch('/me/dark-mode', data: {
          'prefersDarkMode': isDark,
        });
      } catch (e) {
        // Ignore errors when saving to backend (user might not be logged in)
      }
    }
  }
  
  Future<void> loadFromUser(bool prefersDarkMode) async {
    state = prefersDarkMode ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeModeKey, prefersDarkMode);
  }
  
  void toggle() {
    final isDark = state == ThemeMode.dark;
    setThemeMode(!isDark);
  }
}

/// Provider for theme mode management
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref);
});

