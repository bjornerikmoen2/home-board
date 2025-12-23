import 'package:dio/dio.dart';
import '../models/analytics_models.dart';

class AnalyticsRepository {
  final Dio dio;

  AnalyticsRepository(this.dio);

  Future<AnalyticsModel> getAnalytics({int days = 30}) async {
    final response = await dio.get('/analytics', queryParameters: {'days': days});
    return AnalyticsModel.fromJson(response.data);
  }
}
