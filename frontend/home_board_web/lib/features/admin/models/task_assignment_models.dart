import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_assignment_models.freezed.dart';
part 'task_assignment_models.g.dart';

@Freezed(toJson: true)
class TaskAssignmentModel with _$TaskAssignmentModel {
  const factory TaskAssignmentModel({
    required String id,
    required String taskDefinitionId,
    required String taskTitle,
    String? assignedToUserId,
    String? assignedToName,
    int? assignedToGroup,
    required int scheduleType,
    required int daysOfWeek,
    String? startDate,
    String? endDate,
    String? dueTime,
    required bool isActive,
  }) = _TaskAssignmentModel;

  factory TaskAssignmentModel.fromJson(Map<String, dynamic> json) =>
      _$TaskAssignmentModelFromJson(json);
}

@Freezed(toJson: true)
class CreateTaskAssignmentRequest with _$CreateTaskAssignmentRequest {
  const factory CreateTaskAssignmentRequest({
    required String taskDefinitionId,
    String? assignedToUserId,
    int? assignedToGroup,
    required int scheduleType,
    required int daysOfWeek,
    String? startDate,
    String? endDate,
    String? dueTime,
  }) = _CreateTaskAssignmentRequest;

  factory CreateTaskAssignmentRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTaskAssignmentRequestFromJson(json);
}

@Freezed(toJson: true)
class UpdateTaskAssignmentRequest with _$UpdateTaskAssignmentRequest {
  const factory UpdateTaskAssignmentRequest({
    String? taskDefinitionId,
    String? assignedToUserId,
    int? assignedToGroup,
    int? scheduleType,
    int? daysOfWeek,
    String? startDate,
    String? endDate,
    String? dueTime,
    bool? isActive,
  }) = _UpdateTaskAssignmentRequest;

  factory UpdateTaskAssignmentRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateTaskAssignmentRequestFromJson(json);
}
