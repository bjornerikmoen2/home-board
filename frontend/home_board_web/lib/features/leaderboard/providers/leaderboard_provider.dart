import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/leaderboard_models.dart';
import '../repositories/leaderboard_repository.dart';

part 'leaderboard_provider.g.dart';

@riverpod
class Leaderboard extends _$Leaderboard {
  String _currentPeriod = 'week';

  @override
  Future<List<LeaderboardEntryModel>> build() async {
    return _fetchLeaderboard(_currentPeriod);
  }

  Future<List<LeaderboardEntryModel>> _fetchLeaderboard(String period) async {
    final repository = ref.read(leaderboardRepositoryProvider);
    return await repository.getLeaderboard(period: period);
  }

  Future<void> setPeriod(String period) async {
    _currentPeriod = period;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchLeaderboard(period));
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchLeaderboard(_currentPeriod));
  }
}
