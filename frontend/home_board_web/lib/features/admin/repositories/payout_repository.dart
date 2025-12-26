import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_provider.dart';
import '../models/payout_models.dart';

part 'payout_repository.g.dart';

@riverpod
PayoutRepository payoutRepository(PayoutRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  return PayoutRepository(dio);
}

class PayoutRepository {
  final Dio _dio;

  PayoutRepository(this._dio);

  Future<PayoutPreviewResponseModel> getPayoutPreview() async {
    try {
      final response = await _dio.get('/payout/preview');
      return PayoutPreviewResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<ExecutePayoutResponseModel> executePayout(
      ExecutePayoutRequestModel request) async {
    try {
      final response = await _dio.post(
        '/payout/execute',
        data: request.toJson(),
      );
      return ExecutePayoutResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
