import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../domain/models/game_settings.dart';
import '../../../domain/repositories/settings_repository.dart';

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, GameSettings>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repo);
});

class SettingsNotifier extends StateNotifier<GameSettings> {
  final SettingsRepository repository;

  SettingsNotifier(this.repository) : super(const GameSettings()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final settings = await repository.getSettings();
    state = settings;
  }

  Future<void> updateSettings(GameSettings newSettings) async {
    state = newSettings;
    await repository.saveSettings(newSettings);
  }

  Future<void> toggleSound() async {
    final updated = state.copyWith(soundEnabled: !state.soundEnabled);
    await updateSettings(updated);
  }

  Future<void> toggleHaptics() async {
    final updated = state.copyWith(hapticsEnabled: !state.hapticsEnabled);
    await updateSettings(updated);
  }

  Future<void> toggleDrinkingMode() async {
    final updated = state.copyWith(
      drinkingMode: !state.drinkingMode,
      familyFriendlyMode: state.drinkingMode ? true : false,
    );
    await updateSettings(updated);
  }

  Future<void> toggleFamilyFriendly() async {
    final updated = state.copyWith(
      familyFriendlyMode: !state.familyFriendlyMode,
      drinkingMode: !state.familyFriendlyMode ? false : state.drinkingMode,
    );
    await updateSettings(updated);
  }

  Future<void> setLanguage(String lang) async {
    final updated = state.copyWith(language: lang);
    await updateSettings(updated);
  }

  Future<void> setDuration(int seconds) async {
    final updated = state.copyWith(roundDurationSeconds: seconds);
    await updateSettings(updated);
  }

  Future<void> toggleTheme() async {
    final updated = state.copyWith(isDarkMode: !state.isDarkMode);
    await updateSettings(updated);
  }

  Future<void> setRounds(int rounds) async {
    final updated = state.copyWith(totalRounds: rounds);
    await updateSettings(updated);
  }

  Future<void> setDifficulty(String diff) async {
    final updated = state.copyWith(difficulty: diff);
    await updateSettings(updated);
  }
}
