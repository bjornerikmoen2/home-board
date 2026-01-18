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

// Provider to get scoreboard data (only when enabled)
final scoreboardDataProvider = FutureProvider<ScoreboardResponse?>((ref) async {
  final repository = ref.watch(scoreboardRepositoryProvider);
  final isEnabled = await ref.watch(scoreboardEnabledProvider.future);
  
  if (!isEnabled) {
    return null;
  }
  
  try {
    return await repository.getScoreboard();
  } catch (e) {
    return null;
  }
});
