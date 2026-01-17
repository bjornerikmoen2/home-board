import 'package:freezed_annotation/freezed_annotation.dart';

part 'scoreboard_models.freezed.dart';
part 'scoreboard_models.g.dart';

@freezed
class ScoreboardResponse with _$ScoreboardResponse {
  const factory ScoreboardResponse({
    required List<UserScoreboard> users,
  }) = _ScoreboardResponse;

  factory ScoreboardResponse.fromJson(Map<String, dynamic> json) =>
      _$ScoreboardResponseFromJson(json);
}

@freezed
class UserScoreboard with _$UserScoreboard {
  const factory UserScoreboard({
    required String id,
    required String name,
    required int points,
    required List<ScoreboardTask> tasks,
  }) = _UserScoreboard;

  factory UserScoreboard.fromJson(Map<String, dynamic> json) =>
      _$UserScoreboardFromJson(json);
}

@freezed
class ScoreboardTask with _$ScoreboardTask {
  const factory ScoreboardTask({
    required String id,
    required String title,
    required int points,
  }) = _ScoreboardTask;

  factory ScoreboardTask.fromJson(Map<String, dynamic> json) =>
      _$ScoreboardTaskFromJson(json);
}
