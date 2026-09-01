import '../models/word.dart';

abstract class WordRepository {
  Future<List<GameWord>> getAllWords();
  Future<List<GameWord>> getWordsForGame({
    required List<String> categoryIds,
    required String difficulty,
    required bool familyFriendlyOnly,
    required bool isDrinkingMode,
  });
  Future<GameWord?> getWordById(String id);
  Future<List<GameWord>> searchWords(String query);
}
