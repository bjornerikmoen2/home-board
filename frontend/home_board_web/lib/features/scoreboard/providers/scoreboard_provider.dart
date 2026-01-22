import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../models/scoreboard_models.dart';
import '../repositories/scoreboard_repository.dart';

final scoreboardRepositoryProvider = Provider<ScoreboardRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ScoreboardRepository(dio);
});

// Provider to check if scoreboard is enabled
final scoreboardEnabledProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(scoreboardRepositoryProvider);
  try {
    if (kDebugMode) {
      print('Fetching scoreboard enabled status...');
    }
    final result = await repository.isScoreboardEnabled();
    if (kDebugMode) {
      print('Scoreboard enabled: $result');
    }
    return result;
  } catch (e) {
    if (kDebugMode) {
      print('Error fetching scoreboard enabled status: $e');
    }
    return false;
  }
});

// Auto-refresh notifier for triggering updates
class AutoRefreshNotifier extends StateNotifier<int> {
  Timer? _timer;
  
  AutoRefreshNotifier() : super(0) {
    _startAutoRefresh();
  }
  
  void _startAutoRefresh() {
    // Refresh every 5 minutes (300 seconds)
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (kDebugMode) {
        print('Auto-refreshing scoreboard data...');
      }
      state++; // Increment state to trigger refresh
    });
  }
  
  void manualRefresh() {
    if (kDebugMode) {
      print('Manual refresh triggered');
    }
    state++;
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final autoRefreshProvider = StateNotifierProvider<AutoRefreshNotifier, int>((ref) {
  return AutoRefreshNotifier();
});

// Provider to get scoreboard data (only when enabled) with auto-refresh
final scoreboardDataProvider = FutureProvider<ScoreboardResponse?>((ref) async {
  final repository = ref.watch(scoreboardRepositoryProvider);
  final isEnabled = await ref.watch(scoreboardEnabledProvider.future);
  
  // Watch the auto-refresh provider to trigger updates
  ref.watch(autoRefreshProvider);
  
  if (!isEnabled) {
    return null;
  }
  
  try {
    if (kDebugMode) {
      print('Fetching scoreboard data at ${DateTime.now()}');
    }
    return await repository.getScoreboard();
  } catch (e) {
    if (kDebugMode) {
      print('Error fetching scoreboard data: $e');
    }
    return null;
  }
});
