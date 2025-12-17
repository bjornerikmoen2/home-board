import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_definition_models.freezed.dart';
part 'task_definition_models.g.dart';

@freezed
class TaskDefinitionManagementModel with _$TaskDefinitionManagementModel {
  const factory TaskDefinitionManagementModel({
    required String id,
    required String title,
    String? description,
    required int defaultPoints,
    required bool isActive,
  }) = _TaskDefinitionManagementModel;

  factory TaskDefinitionManagementModel.fromJson(Map<String, dynamic> json) =>
      _$TaskDefinitionManagementModelFromJson(json);
}

@freezed
class CreateTaskDefinitionRequestModel
    with _$CreateTaskDefinitionRequestModel {
  const factory CreateTaskDefinitionRequestModel({
    required String title,
    String? description,
    required int defaultPoints,
  }) = _CreateTaskDefinitionRequestModel;

  factory CreateTaskDefinitionRequestModel.fromJson(
          Map<String, dynamic> json) =>
      _$CreateTaskDefinitionRequestModelFromJson(json);
}

@freezed
class UpdateTaskDefinitionRequestModel
    with _$UpdateTaskDefinitionRequestModel {
  const factory UpdateTaskDefinitionRequestModel({
    String? title,
    String? description,
    int? defaultPoints,
    bool? isActive,
  }) = _UpdateTaskDefinitionRequestModel;

  factory UpdateTaskDefinitionRequestModel.fromJson(
          Map<String, dynamic> json) =>
      _$UpdateTaskDefinitionRequestModelFromJson(json);
}
