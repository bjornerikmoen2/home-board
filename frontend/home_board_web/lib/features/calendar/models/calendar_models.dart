import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_models.freezed.dart';
part 'calendar_models.g.dart';

@freezed
class CalendarTaskModel with _$CalendarTaskModel {
  const factory CalendarTaskModel({
    required String assignmentId,
    required String date,
    required String title,
    String? description,
    String? assignedToUserId,
    String? assignedToName,
    int? assignedToGroup,
    String? dueTime,
    required int defaultPoints,
    required bool isCompleted,
    String? completionId,
    int? status,
  }) = _CalendarTaskModel;

  factory CalendarTaskModel.fromJson(Map<String, dynamic> json) =>
      _$CalendarTaskModelFromJson(json);
}
