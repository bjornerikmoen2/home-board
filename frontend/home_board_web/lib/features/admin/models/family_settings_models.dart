import 'package:freezed_annotation/freezed_annotation.dart';

part 'family_settings_models.freezed.dart';
part 'family_settings_models.g.dart';

@freezed
class FamilySettingsModel with _$FamilySettingsModel {
  const factory FamilySettingsModel({
    required String id,
    required String timezone,
    required double pointToMoneyRate,
    required int weekStartsOn,
    required bool enableScoreboard,
    required bool includeAdminsInAssignments,
  }) = _FamilySettingsModel;

  factory FamilySettingsModel.fromJson(Map<String, dynamic> json) =>
      _$FamilySettingsModelFromJson(json);
}

@freezed
class UpdateFamilySettingsRequest with _$UpdateFamilySettingsRequest {
  const factory UpdateFamilySettingsRequest({
    String? timezone,
    double? pointToMoneyRate,
    int? weekStartsOn,
    bool? enableScoreboard,
    bool? includeAdminsInAssignments,
  }) = _UpdateFamilySettingsRequest;

  factory UpdateFamilySettingsRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateFamilySettingsRequestFromJson(json);
}
