enum TiltControlMode { tilt, tap }

enum TiltSensitivity { low, medium, high }

class GameSettings {
  final int roundDurationSeconds;
  final int totalRounds;
  final String difficulty; // 'all', 'easy', 'medium', 'hard'
  final List<String> selectedCategoryIds;
  final bool allowPassing;
  final int passPenalty; // 0 or -1
  final bool drinkingMode;
  final String drinkingPenaltyType; // 'sip', 'shot', 'dare'
  final String finalKingPenalty; // 'sip', 'shot', 'challenge', 'forfeit'
  final bool familyFriendlyMode;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool showPassCount;
  final TiltControlMode controlMode;
  final TiltSensitivity sensitivity;
  final String language; // 'en' or 'sw'

  const GameSettings({
    this.roundDurationSeconds = 60,
    this.totalRounds = 3,
    this.difficulty = 'all',
    this.selectedCategoryIds = const [],
    this.allowPassing = true,
    this.passPenalty = 0,
    this.drinkingMode = false,
    this.drinkingPenaltyType = 'sip',
    this.finalKingPenalty = 'sip',
    this.familyFriendlyMode = true,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.showPassCount = true,
    this.controlMode = TiltControlMode.tilt,
    this.sensitivity = TiltSensitivity.medium,
    this.language = 'en',
  });

  GameSettings copyWith({
    int? roundDurationSeconds,
    int? totalRounds,
    String? difficulty,
    List<String>? selectedCategoryIds,
    bool? allowPassing,
    int? passPenalty,
    bool? drinkingMode,
    String? drinkingPenaltyType,
    String? finalKingPenalty,
    bool? familyFriendlyMode,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? showPassCount,
    TiltControlMode? controlMode,
    TiltSensitivity? sensitivity,
    String? language,
  }) {
    return GameSettings(
      roundDurationSeconds: roundDurationSeconds ?? this.roundDurationSeconds,
      totalRounds: totalRounds ?? this.totalRounds,
      difficulty: difficulty ?? this.difficulty,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      allowPassing: allowPassing ?? this.allowPassing,
      passPenalty: passPenalty ?? this.passPenalty,
      drinkingMode: drinkingMode ?? this.drinkingMode,
      drinkingPenaltyType: drinkingPenaltyType ?? this.drinkingPenaltyType,
      finalKingPenalty: finalKingPenalty ?? this.finalKingPenalty,
      familyFriendlyMode: familyFriendlyMode ?? this.familyFriendlyMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      showPassCount: showPassCount ?? this.showPassCount,
      controlMode: controlMode ?? this.controlMode,
      sensitivity: sensitivity ?? this.sensitivity,
      language: language ?? this.language,
    );
  }
}
