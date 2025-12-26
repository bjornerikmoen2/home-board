import 'package:freezed_annotation/freezed_annotation.dart';

part 'no_password_user_model.freezed.dart';
part 'no_password_user_model.g.dart';

@freezed
class NoPasswordUserModel with _$NoPasswordUserModel {
  const factory NoPasswordUserModel({
    required String id,
    required String username,
    required String displayName,
    String? profileImageUrl,
  }) = _NoPasswordUserModel;

  factory NoPasswordUserModel.fromJson(Map<String, dynamic> json) =>
      _$NoPasswordUserModelFromJson(json);
}
