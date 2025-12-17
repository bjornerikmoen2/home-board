import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_provider.dart';
import '../models/leaderboard_models.dart';

part 'leaderboard_repository.g.dart';

@riverpod
LeaderboardRepository leaderboardRepository(LeaderboardRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  return LeaderboardRepository(dio);
}

class LeaderboardRepository {
  final Dio _dio;

  LeaderboardRepository(this._dio);

  Future<List<LeaderboardEntryModel>> getLeaderboard({
    String period = 'week',
  }) async {
    try {
      final response = await _dio.get(
        '/leaderboard',
        queryParameters: {'period': period},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => LeaderboardEntryModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
