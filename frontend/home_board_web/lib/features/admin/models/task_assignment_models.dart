import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_assignment_models.freezed.dart';
part 'task_assignment_models.g.dart';

@freezed
class TaskAssignmentModel with _$TaskAssignmentModel {
  const factory TaskAssignmentModel({
    required String id,
    required String taskDefinitionId,
    required String taskTitle,
    required String assignedToUserId,
    required String assignedToName,
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

@freezed
class CreateTaskAssignmentRequest with _$CreateTaskAssignmentRequest {
  const factory CreateTaskAssignmentRequest({
    required String taskDefinitionId,
    required String assignedToUserId,
    required int scheduleType,
    required int daysOfWeek,
    String? startDate,
    String? endDate,
    String? dueTime,
  }) = _CreateTaskAssignmentRequest;

  factory CreateTaskAssignmentRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTaskAssignmentRequestFromJson(json);
}

@freezed
class UpdateTaskAssignmentRequest with _$UpdateTaskAssignmentRequest {
  const factory UpdateTaskAssignmentRequest({
    bool? isActive,
    String? dueTime,
  }) = _UpdateTaskAssignmentRequest;

  factory UpdateTaskAssignmentRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateTaskAssignmentRequestFromJson(json);
}
