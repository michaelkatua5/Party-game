import '../../domain/models/word.dart';
import '../../domain/repositories/word_repository.dart';
import '../datasources/local_word_datasource.dart';

class WordRepositoryImpl implements WordRepository {
  final LocalWordDatasource datasource;

  WordRepositoryImpl({required this.datasource});

  @override
  Future<List<GameWord>> getAllWords() async {
    return await datasource.loadWords();
  }

  @override
  Future<List<GameWord>> getWordsForGame({
    required List<String> categoryIds,
    required String difficulty,
    required bool familyFriendlyOnly,
    required bool isDrinkingMode,
  }) async {
    final allWords = await datasource.loadWords();

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

      return true;
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
