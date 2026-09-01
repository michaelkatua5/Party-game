import '../models/game_stats.dart';
import '../models/achievement.dart';

abstract class StatsRepository {
  Future<GameStats> getStats();
  Future<void> updateGameEnded({
    required bool won,
    required int correctAnswers,
    required int passedAnswers,
    required int streak,
    required String categoryId,
  });
  Future<List<Achievement>> getAchievements();
  Future<void> unlockAchievement(String achievementId);
}
