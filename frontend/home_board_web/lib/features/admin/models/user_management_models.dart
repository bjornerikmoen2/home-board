import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_management_models.freezed.dart';
part 'user_management_models.g.dart';

@freezed
class UserManagementModel with _$UserManagementModel {
  const factory UserManagementModel({
    required String id,
    required String username,
    required String displayName,
    required String role,
  }) = _UserManagementModel;

  factory UserManagementModel.fromJson(Map<String, dynamic> json) =>
      _$UserManagementModelFromJson(json);
}

@freezed
class CreateUserRequestModel with _$CreateUserRequestModel {
  const factory CreateUserRequestModel({
    required String username,
    required String displayName,
    required String password,
    required String role,
  }) = _CreateUserRequestModel;

  factory CreateUserRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CreateUserRequestModelFromJson(json);
}

@freezed
class UpdateUserRequestModel with _$UpdateUserRequestModel {
  const factory UpdateUserRequestModel({
    String? displayName,
    bool? isActive,
    String? role,
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
