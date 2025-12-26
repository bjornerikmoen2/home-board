import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:typed_data';

part 'user_management_models.freezed.dart';
part 'user_management_models.g.dart';

@freezed
class UserManagementModel with _$UserManagementModel {
  const factory UserManagementModel({
    required String id,
    required String username,
    required String displayName,
    required String role,
    @Default('en') String preferredLanguage,
    @Default(false) bool noPasswordRequired,
    String? profileImageUrl,
  }) = _UserManagementModel;

  factory UserManagementModel.fromJson(Map<String, dynamic> json) =>
      _$UserManagementModelFromJson(json);
}

@freezed
class CreateUserRequestModel with _$CreateUserRequestModel {
  const factory CreateUserRequestModel({
    required String username,
    required String displayName,
    String? password,
    required String role,
    @Default(false) bool noPasswordRequired,
    @Default('en') String preferredLanguage,
    @JsonKey(includeFromJson: false, includeToJson: false) Uint8List? profileImage,
    @JsonKey(includeFromJson: false, includeToJson: false) String? profileImageName,
  }) = _CreateUserRequestModel;

  factory CreateUserRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CreateUserRequestModelFromJson(json);
}

@freezed
class UpdateUserRequestModel with _$UpdateUserRequestModel {
  const factory UpdateUserRequestModel({
    String? displayName,
    bool? isActive,
    bool? noPasswordRequired,
    String? role,
    String? preferredLanguage,
    @JsonKey(includeFromJson: false, includeToJson: false) Uint8List? profileImage,
    @JsonKey(includeFromJson: false, includeToJson: false) String? profileImageName,
    @JsonKey(includeFromJson: false, includeToJson: false) bool? removeProfileImage,
  }) = _UpdateUserRequestModel;

  factory UpdateUserRequestModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserRequestModelFromJson(json);
}

@freezed
class ResetPasswordRequestModel with _$ResetPasswordRequestModel {
  const factory ResetPasswordRequestModel({
    required String newPassword,
  }) = _ResetPasswordRequestModel;

  factory ResetPasswordRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestModelFromJson(json);
}

@freezed
class BonusPointsRequestModel with _$BonusPointsRequestModel {
  const factory BonusPointsRequestModel({
    required int points,
    String? description,
  }) = _BonusPointsRequestModel;

  factory BonusPointsRequestModel.fromJson(Map<String, dynamic> json) =>
      _$BonusPointsRequestModelFromJson(json);
}
