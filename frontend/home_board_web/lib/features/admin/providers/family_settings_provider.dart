import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../models/family_settings_models.dart';
import '../repositories/family_settings_repository.dart';

final familySettingsRepositoryProvider = Provider<FamilySettingsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return FamilySettingsRepository(dio);
});

final familySettingsProvider =
    FutureProvider<FamilySettingsModel>((ref) async {
  final repository = ref.watch(familySettingsRepositoryProvider);
  return repository.getFamilySettings();
});

class FamilySettingsNotifier extends StateNotifier<AsyncValue<FamilySettingsModel>> {
  final FamilySettingsRepository _repository;

  FamilySettingsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getFamilySettings());
  }

  Future<void> updateSettings(UpdateFamilySettingsRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.updateFamilySettings(request),
    );
  }

  Future<void> refresh() async {
    await _load();
  }
}

final familySettingsNotifierProvider =
    StateNotifierProvider<FamilySettingsNotifier, AsyncValue<FamilySettingsModel>>(
  (ref) {
    final repository = ref.watch(familySettingsRepositoryProvider);
    return FamilySettingsNotifier(repository);
  },
);
