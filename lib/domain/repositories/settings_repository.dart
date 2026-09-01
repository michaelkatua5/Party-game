import '../models/game_settings.dart';

abstract class SettingsRepository {
  Future<GameSettings> getSettings();
  Future<void> saveSettings(GameSettings settings);
}
