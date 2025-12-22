import 'package:dio/dio.dart';
import '../models/calendar_models.dart';

class CalendarRepository {
  final Dio dio;

  CalendarRepository(this.dio);

  Future<List<CalendarTaskModel>> getCalendarTasks(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await dio.get(
      '/tasks/calendar',
      queryParameters: {
        'startDate': startDate.toIso8601String().split('T')[0],
        'endDate': endDate.toIso8601String().split('T')[0],
      },
    );

    return (response.data as List)
        .map((json) => CalendarTaskModel.fromJson(json))
        .toList();
  }
}
