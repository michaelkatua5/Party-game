import 'package:flutter/services.dart';

enum GameSound {
  buttonTap,
  countdownTick,
  countdownGo,
  correct,
  pass,
  wrong,
  timeWarning,
  timeUp,
  victoryFanfare,
}

abstract class AudioService {
  Future<void> play(GameSound sound);
  void setEnabled(bool enabled);
}

class SystemAudioService implements AudioService {
  bool _enabled = true;

  @override
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  @override
  Future<void> play(GameSound sound) async {
    if (!_enabled) return;

    try {
      switch (sound) {
        case GameSound.buttonTap:
        case GameSound.countdownTick:
          await SystemSound.play(SystemSoundType.click);
          break;
        case GameSound.countdownGo:
        case GameSound.correct:
        case GameSound.pass:
        case GameSound.wrong:
        case GameSound.timeWarning:
        case GameSound.timeUp:
        case GameSound.victoryFanfare:
          await SystemSound.play(SystemSoundType.alert);
          break;
      }
    } catch (_) {
      // Gracefully handle platform sound unavailability
    }
  }
}
