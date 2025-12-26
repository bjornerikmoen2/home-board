import 'package:freezed_annotation/freezed_annotation.dart';

part 'payout_models.freezed.dart';
part 'payout_models.g.dart';

@freezed
class PayoutPreviewModel with _$PayoutPreviewModel {
  const factory PayoutPreviewModel({
    required String userId,
    required String displayName,
    DateTime? lastPayoutAt,
    required DateTime periodStart,
    required DateTime periodEnd,
    required int netPointsSinceLastPayout,
    required double pointToMoneyRate,
    required double moneyToPay,
  }) = _PayoutPreviewModel;

  factory PayoutPreviewModel.fromJson(Map<String, dynamic> json) =>
      _$PayoutPreviewModelFromJson(json);
}

@freezed
class PayoutPreviewResponseModel with _$PayoutPreviewResponseModel {
  const factory PayoutPreviewResponseModel({
    required List<PayoutPreviewModel> userPayouts,
    required double totalMoneyToPay,
    required double pointToMoneyRate,
  }) = _PayoutPreviewResponseModel;

  factory PayoutPreviewResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PayoutPreviewResponseModelFromJson(json);
}

@freezed
class ExecutePayoutRequestModel with _$ExecutePayoutRequestModel {
  const factory ExecutePayoutRequestModel({
    List<String>? userIds,
    String? note,
  }) = _ExecutePayoutRequestModel;

  factory ExecutePayoutRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ExecutePayoutRequestModelFromJson(json);
}

@freezed
class PayoutModel with _$PayoutModel {
  const factory PayoutModel({
    required String id,
    required String userId,
    required String displayName,
    required DateTime periodStart,
    required DateTime periodEnd,
    required int netPoints,
    required double pointToMoneyRate,
    required double moneyPaid,
    required DateTime paidAt,
    String? note,
  }) = _PayoutModel;

  factory PayoutModel.fromJson(Map<String, dynamic> json) =>
      _$PayoutModelFromJson(json);
}

@freezed
class ExecutePayoutResponseModel with _$ExecutePayoutResponseModel {
  const factory ExecutePayoutResponseModel({
    required List<PayoutModel> payouts,
    required double totalMoneyPaid,
    required int usersProcessed,
  }) = _ExecutePayoutResponseModel;

  factory ExecutePayoutResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ExecutePayoutResponseModelFromJson(json);
}
