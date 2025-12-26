import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_models.freezed.dart';
part 'analytics_models.g.dart';

@freezed
class AnalyticsModel with _$AnalyticsModel {
  const factory AnalyticsModel({
    required List<CompletionRateDataPoint> completionRates,
    required PointsAnalytics pointsAnalytics,
  }) = _AnalyticsModel;

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsModelFromJson(json);
}

@freezed
class CompletionRateDataPoint with _$CompletionRateDataPoint {
  const factory CompletionRateDataPoint({
    required DateTime date,
    required int totalTasks,
    required int completedTasks,
    required double completionRate,
  }) = _CompletionRateDataPoint;

  factory CompletionRateDataPoint.fromJson(Map<String, dynamic> json) =>
      _$CompletionRateDataPointFromJson(json);
}

@freezed
class PointsAnalytics with _$PointsAnalytics {
  const factory PointsAnalytics({
    required List<PointsDataPoint> pointsEarned,
    required List<MoneyDataPoint> moneyPaidOut,
    required int totalEarned,
    required double totalPaidOut,
    required int currentBalance,
  }) = _PointsAnalytics;

  factory PointsAnalytics.fromJson(Map<String, dynamic> json) =>
      _$PointsAnalyticsFromJson(json);
}

@freezed
class PointsDataPoint with _$PointsDataPoint {
  const factory PointsDataPoint({
    required DateTime date,
    required int amount,
  }) = _PointsDataPoint;

  factory PointsDataPoint.fromJson(Map<String, dynamic> json) =>
      _$PointsDataPointFromJson(json);
}

@freezed
class MoneyDataPoint with _$MoneyDataPoint {
  const factory MoneyDataPoint({
    required DateTime date,
    required double amount,
  }) = _MoneyDataPoint;

  factory MoneyDataPoint.fromJson(Map<String, dynamic> json) =>
      _$MoneyDataPointFromJson(json);
}
