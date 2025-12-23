import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_provider.dart';
import '../models/analytics_models.dart';
import '../repositories/analytics_repository.dart';

part 'analytics_provider.g.dart';

@riverpod
class AnalyticsNotifier extends _$AnalyticsNotifier {
  late final AnalyticsRepository _repository;

  @override
  Future<AnalyticsModel> build({int days = 30}) async {
    _repository = AnalyticsRepository(ref.watch(dioProvider));
    return _repository.getAnalytics(days: days);
  }

  Future<void> refresh({int days = 30}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAnalytics(days: days));
  }
}
