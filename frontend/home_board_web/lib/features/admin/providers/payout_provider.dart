import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/payout_models.dart';
import '../repositories/payout_repository.dart';

part 'payout_provider.g.dart';

@riverpod
class PayoutPreview extends _$PayoutPreview {
  @override
  Future<PayoutPreviewResponseModel> build() async {
    return _fetchPreview();
  }

  Future<PayoutPreviewResponseModel> _fetchPreview() async {
    final repository = ref.read(payoutRepositoryProvider);
    return await repository.getPayoutPreview();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPreview());
  }

  Future<ExecutePayoutResponseModel> executePayout({
    List<String>? userIds,
    String? note,
  }) async {
    try {
      final repository = ref.read(payoutRepositoryProvider);
      final request = ExecutePayoutRequestModel(
        userIds: userIds,
        note: note,
      );
      final response = await repository.executePayout(request);
      
      // Refresh the preview after executing
      await refresh();
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
