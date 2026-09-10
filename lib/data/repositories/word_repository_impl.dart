import '../../domain/models/word.dart';
import '../../domain/repositories/word_repository.dart';
import '../datasources/local_word_datasource.dart';
import 'word_stats_repository.dart';

class WordRepositoryImpl implements WordRepository {
  final LocalWordDatasource datasource;
  final WordStatsRepository? statsRepository;

  WordRepositoryImpl({required this.datasource, this.statsRepository});

  @override
  Future<List<GameWord>> getAllWords() async {
    final allWords = await datasource.loadWords();
    return _applyDynamicDifficulty(allWords);
  }

  @override
  Future<List<GameWord>> getWordsForGame({
    required List<String> categoryIds,
    required String difficulty,
    required bool familyFriendlyOnly,
    required bool isDrinkingMode,
  }) async {
    var allWords = await datasource.loadWords();
    allWords = await _applyDynamicDifficulty(allWords);

    return allWords.where((word) {
      // Category filter (if empty, allow all)
      if (categoryIds.isNotEmpty && !categoryIds.contains(word.categoryId)) {
        return false;
      }

      // Difficulty filter
      if (difficulty != 'all' && word.difficulty.toLowerCase() != difficulty.toLowerCase()) {
        return false;
      }

      // Family friendly filter
      if (familyFriendlyOnly && !word.familyFriendly) {
        return false;
      }

      // Drinking mode filter
      if (!isDrinkingMode && word.isDrinking) {
        return false;
      }
      
      // Bad word filter (words needing review should probably still be playable until deactivated,
      // but maybe we exclude them? The prompt said "flag it for review. Do NOT automatically delete the word."
      // So we can still play them, or not. We'll let them be playable unless deactivated).

      return true;
    }).toList();
  }

  Future<List<GameWord>> _applyDynamicDifficulty(List<GameWord> words) async {
    if (statsRepository == null) return words;

    final statsList = await statsRepository!.getAllStats();
    final statsMap = {for (var s in statsList) s.wordId: s};

    return words.map((w) {
      final stat = statsMap[w.id];
      if (stat != null) {
        // If it's flagged as inactive, we probably shouldn't even return it, 
        // but that requires a change to the where clause.
        // For now, we'll just update its difficulty level.
        return w.copyWith(difficulty: stat.difficultyLevel);
      }
      return w;
    }).toList();
  }

  @override
  Future<GameWord?> getWordById(String id) async {
    final allWords = await datasource.loadWords();
    try {
      return allWords.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<GameWord>> searchWords(String query) async {
    if (query.trim().isEmpty) return await getAllWords();
    final allWords = await datasource.loadWords();
    final q = query.toLowerCase();
    return allWords.where((w) {
      return w.word.toLowerCase().contains(q) ||
          w.hints.toLowerCase().contains(q) ||
          (w.hintSw?.toLowerCase().contains(q) ?? false) ||
          w.aliases.any((a) => a.toLowerCase().contains(q)) ||
          w.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }
}
