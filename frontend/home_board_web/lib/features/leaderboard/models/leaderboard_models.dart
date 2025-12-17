import 'package:freezed_annotation/freezed_annotation.dart';

part 'leaderboard_models.freezed.dart';
part 'leaderboard_models.g.dart';

@freezed
class LeaderboardEntryModel with _$LeaderboardEntryModel {
  const factory LeaderboardEntryModel({
    required int rank,
    required String userName,
    required String displayName,
    required int totalPoints,
    required int tasksCompleted,
  }) = _LeaderboardEntryModel;

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryModelFromJson(json);
}
