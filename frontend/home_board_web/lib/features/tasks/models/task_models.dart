import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_models.freezed.dart';
part 'task_models.g.dart';

@freezed
class TaskDefinitionModel with _$TaskDefinitionModel {
  const factory TaskDefinitionModel({
    required int id,
    required String name,
    required String description,
    required int pointValue,
    required bool requiresVerification,
    required String scheduleType,
    int? dayOfWeekFlags,
    int? dayOfMonth,
    DateTime? specificDate,
    bool? isActive,
  }) = _TaskDefinitionModel;

  factory TaskDefinitionModel.fromJson(Map<String, dynamic> json) =>
      _$TaskDefinitionModelFromJson(json);
}

@freezed
class TaskAssignmentModel with _$TaskAssignmentModel {
  const factory TaskAssignmentModel({
    required int id,
    required int taskDefinitionId,
    required int assignedToUserId,
    required DateTime dueDate,
    required String status,
  }) = _TaskAssignmentModel;

  factory TaskAssignmentModel.fromJson(Map<String, dynamic> json) =>
      _$TaskAssignmentModelFromJson(json);
}

@freezed
class TodayTaskModel with _$TodayTaskModel {
  const factory TodayTaskModel({
    required int assignmentId,
    required String taskName,
    required String description,
    required int pointValue,
    required String status,
    required bool requiresVerification,
    DateTime? completedAt,
    DateTime? verifiedAt,
  }) = _TodayTaskModel;

  factory TodayTaskModel.fromJson(Map<String, dynamic> json) =>
      _$TodayTaskModelFromJson(json);
}

@freezed
class TaskCompletionRequest with _$TaskCompletionRequest {
  const factory TaskCompletionRequest({
    String? notes,
    String? photoUrl,
  }) = _TaskCompletionRequest;

  factory TaskCompletionRequest.fromJson(Map<String, dynamic> json) =>
      _$TaskCompletionRequestFromJson(json);
}
