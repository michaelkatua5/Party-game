import '../../core/services/storage_service.dart';
import '../../domain/models/game_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final StorageService storage;

  SettingsRepositoryImpl({required this.storage});

  static const _keyDuration = 'settings_duration';
  static const _keyRounds = 'settings_rounds';
  static const _keyDifficulty = 'settings_difficulty';
  static const _keyCategories = 'settings_categories';
  static const _keyPassing = 'settings_passing';
  static const _keyPenalty = 'settings_penalty';
  static const _keyDrinking = 'settings_drinking';
  static const _keyFamily = 'settings_family';
  static const _keySound = 'settings_sound';
  static const _keyHaptics = 'settings_haptics';
  static const _keyLanguage = 'settings_language';

  @override
  Future<GameSettings> getSettings() async {
    return GameSettings(
      roundDurationSeconds: storage.getInt(_keyDuration) ?? 60,
      totalRounds: storage.getInt(_keyRounds) ?? 3,
      difficulty: storage.getString(_keyDifficulty) ?? 'all',
      selectedCategoryIds: storage.getStringList(_keyCategories) ?? [],
      allowPassing: storage.getBool(_keyPassing) ?? true,
      passPenalty: storage.getInt(_keyPenalty) ?? 0,
      drinkingMode: storage.getBool(_keyDrinking) ?? false,
      familyFriendlyMode: storage.getBool(_keyFamily) ?? true,
      soundEnabled: storage.getBool(_keySound) ?? true,
      hapticsEnabled: storage.getBool(_keyHaptics) ?? true,
      language: storage.getString(_keyLanguage) ?? 'en',
    );
  }

  @override
  Future<void> saveSettings(GameSettings settings) async {
    await storage.setInt(_keyDuration, settings.roundDurationSeconds);
    await storage.setInt(_keyRounds, settings.totalRounds);
    await storage.setString(_keyDifficulty, settings.difficulty);
    await storage.setStringList(_keyCategories, settings.selectedCategoryIds);
    await storage.setBool(_keyPassing, settings.allowPassing);
    await storage.setInt(_keyPenalty, settings.passPenalty);
    await storage.setBool(_keyDrinking, settings.drinkingMode);
    await storage.setBool(_keyFamily, settings.familyFriendlyMode);
    await storage.setBool(_keySound, settings.soundEnabled);
    await storage.setBool(_keyHaptics, settings.hapticsEnabled);
    await storage.setString(_keyLanguage, settings.language);
  }
}
