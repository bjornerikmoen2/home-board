import 'package:dio/dio.dart';
import '../models/scoreboard_models.dart';

class ScoreboardRepository {
  final Dio dio;

  ScoreboardRepository(this.dio);

  Future<bool> isScoreboardEnabled() async {
    final response = await dio.get('/settings/scoreboard-enabled');
    return response.data as bool;
  }

  Future<ScoreboardResponse> getScoreboard() async {
    final response = await dio.get('/scoreboard');
    return ScoreboardResponse.fromJson(response.data);
  }
}
