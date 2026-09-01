import 'dart:convert';
import '../../core/services/storage_service.dart';
import '../../domain/models/game_stats.dart';
import '../../domain/models/achievement.dart';
import '../../domain/repositories/stats_repository.dart';

class StatsRepositoryImpl implements StatsRepository {
  final StorageService storage;

  StatsRepositoryImpl({required this.storage});

  static const _keyStats = 'game_stats_data';
  static const _keyAchievements = 'game_achievements_data';

  @override
  Future<GameStats> getStats() async {
    final raw = storage.getString(_keyStats);
    if (raw == null) return const GameStats();
    try {
      return GameStats.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const GameStats();
    }
  }

  @override
  Future<void> updateGameEnded({
    required bool won,
    required int correctAnswers,
    required int passedAnswers,
    required int streak,
    required String categoryId,
  }) async {
    final current = await getStats();
    final updated = GameStats(
      totalGamesPlayed: current.totalGamesPlayed + 1,
      totalGamesWon: current.totalGamesWon + (won ? 1 : 0),
      totalWordsAnswered: current.totalWordsAnswered + correctAnswers,
      totalWordsPassed: current.totalWordsPassed + passedAnswers,
      longestStreak: streak > current.longestStreak ? streak : current.longestStreak,
      favoriteCategory: categoryId.isNotEmpty ? categoryId : current.favoriteCategory,
    );

    await storage.setString(_keyStats, jsonEncode(updated.toJson()));

    // Check & unlock relevant achievements
    if (updated.totalGamesPlayed >= 1) await unlockAchievement('first_game');
    if (updated.totalGamesWon >= 1) await unlockAchievement('first_win');
    if (updated.totalWordsAnswered >= 10) await unlockAchievement('words_10');
    if (updated.totalWordsAnswered >= 50) await unlockAchievement('words_50');
    if (updated.totalWordsAnswered >= 100) await unlockAchievement('words_100');
    if (streak >= 5) await unlockAchievement('streak_5');
  }

  @override
  Future<List<Achievement>> getAchievements() async {
    final unlockedRaw = storage.getStringList(_keyAchievements) ?? [];
    return _baseAchievements.map((ach) {
      final isUnlocked = unlockedRaw.contains(ach.id);
      return ach.copyWith(isUnlocked: isUnlocked);
    }).toList();
  }

  @override
  Future<void> unlockAchievement(String achievementId) async {
    final list = storage.getStringList(_keyAchievements) ?? [];
    if (!list.contains(achievementId)) {
      list.add(achievementId);
      await storage.setStringList(_keyAchievements, list);
    }
  }

  static const List<Achievement> _baseAchievements = [
    Achievement(
      id: 'first_game',
      title: 'First Step',
      description: 'Play your very first party game session.',
      icon: 'flag',
    ),
    Achievement(
      id: 'first_win',
      title: 'Champ in the Making',
      description: 'Lead your team to victory for the first time.',
      icon: 'trophy',
    ),
    Achievement(
      id: 'words_10',
      title: 'Sheng Apprentice',
      description: 'Correctly act out 10 words.',
      icon: 'flame',
    ),
    Achievement(
      id: 'words_50',
      title: 'Party Starter',
      description: 'Reach 50 correct acting answers.',
      icon: 'sparkles',
    ),
    Achievement(
      id: 'words_100',
      title: 'Kenyan Legend',
      description: 'Score 100 correct cards total.',
      icon: 'star',
    ),
    Achievement(
      id: 'streak_5',
      title: 'Speed Demon',
      description: 'Get a 5-card answer streak without passing.',
      icon: 'bolt',
    ),
  ];
}
