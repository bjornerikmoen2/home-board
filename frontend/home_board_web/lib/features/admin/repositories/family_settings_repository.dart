import 'package:dio/dio.dart';
import '../models/family_settings_models.dart';

class FamilySettingsRepository {
  final Dio dio;

  FamilySettingsRepository(this.dio);

  Future<FamilySettingsModel> getFamilySettings() async {
    final response = await dio.get('/settings');
    return FamilySettingsModel.fromJson(response.data);
  }

  Future<FamilySettingsModel> updateFamilySettings(
      UpdateFamilySettingsRequest request) async {
    final response = await dio.patch(
      '/settings',
      data: request.toJson(),
    );
    return FamilySettingsModel.fromJson(response.data);
  }
}
