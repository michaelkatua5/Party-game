import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

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
  buzzer,
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

  Future<void> _playAsset(String path, {Duration? durationLimit}) async {
    final player = AudioPlayer();
    await player.play(AssetSource(path));
    
    if (durationLimit != null) {
      Future.delayed(durationLimit, () async {
        await player.stop();
        player.dispose();
      });
    } else {
      player.onPlayerComplete.listen((_) => player.dispose());
    }
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
        case GameSound.correct:
          await _playAsset('audio/correct.wav');
          break;
        case GameSound.pass:
          await _playAsset('audio/pass.wav');
          break;
        case GameSound.buzzer:
          await _playAsset('audio/buzzer.wav', durationLimit: const Duration(milliseconds: 1200));
          break;
        case GameSound.countdownGo:
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
