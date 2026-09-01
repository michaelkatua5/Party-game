abstract class AnalyticsService {
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]);
  Future<void> logAppOpen();
  Future<void> logGameStarted({
    required String mode,
    required int playerCount,
    required int teamCount,
    required List<String> categories,
  });
  Future<void> logGameCompleted({
    required String mode,
    required int durationSeconds,
    required int totalWordsAnswered,
    required int winningScore,
  });
  Future<void> logWordAnswered({
    required String wordId,
    required String categoryId,
    required bool correct,
  });
  Future<void> logAchievementUnlocked(String achievementId);
}

class LocalAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]) async {
    // In production, this proxies to FirebaseAnalytics.instance.logEvent()
  }

  @override
  Future<void> logAppOpen() async {
    await logEvent('app_opened');
  }

  @override
  Future<void> logGameStarted({
    required String mode,
    required int playerCount,
    required int teamCount,
    required List<String> categories,
  }) async {
    await logEvent('game_started', {
      'mode': mode,
      'player_count': playerCount,
      'team_count': teamCount,
      'categories_count': categories.length,
    });
  }

  @override
  Future<void> logGameCompleted({
    required String mode,
    required int durationSeconds,
    required int totalWordsAnswered,
    required int winningScore,
  }) async {
    await logEvent('game_completed', {
      'mode': mode,
      'duration_seconds': durationSeconds,
      'words_count': totalWordsAnswered,
      'winning_score': winningScore,
    });
  }

  @override
  Future<void> logWordAnswered({
    required String wordId,
    required String categoryId,
    required bool correct,
  }) async {
    await logEvent(correct ? 'word_answered_correct' : 'word_passed', {
      'word_id': wordId,
      'category_id': categoryId,
    });
  }

  @override
  Future<void> logAchievementUnlocked(String achievementId) async {
    await logEvent('achievement_unlocked', {'achievement_id': achievementId});
  }
}
