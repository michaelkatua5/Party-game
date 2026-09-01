import 'package:flutter_test/flutter_test.dart';
import 'package:cheza_game/data/datasources/local_word_datasource.dart';
import 'package:cheza_game/data/repositories/word_repository_impl.dart';
import 'package:cheza_game/domain/models/word.dart';

class MockWordDatasource extends LocalWordDatasource {
  @override
  Future<List<GameWord>> loadWords() async {
    return const [
      GameWord(id: 'w1', word: 'Ugali', categoryId: 'food', difficulty: 'easy', familyFriendly: true, isDrinking: false),
      GameWord(id: 'w2', word: 'Mutura', categoryId: 'food', difficulty: 'medium', familyFriendly: true, isDrinking: false),
      GameWord(id: 'w3', word: 'Sheng Card', categoryId: 'sheng', difficulty: 'hard', familyFriendly: true, isDrinking: false),
      GameWord(id: 'w4', word: 'Tequila Shot', categoryId: 'sherehe', difficulty: 'easy', familyFriendly: false, isDrinking: true),
    ];
  }
}

void main() {
  group('WordRepository Deck Filtering Tests', () {
    late WordRepositoryImpl repo;

    setUp(() {
      repo = WordRepositoryImpl(datasource: MockWordDatasource());
    });

    test('Filters by category correctly', () async {
      final words = await repo.getWordsForGame(
        categoryIds: ['food'],
        difficulty: 'all',
        familyFriendlyOnly: false,
        isDrinkingMode: true,
      );

      expect(words.length, equals(2));
      expect(words.every((w) => w.categoryId == 'food'), isTrue);
    });

    test('Filters by difficulty correctly', () async {
      final words = await repo.getWordsForGame(
        categoryIds: [],
        difficulty: 'medium',
        familyFriendlyOnly: false,
        isDrinkingMode: true,
      );

      expect(words.length, equals(1));
      expect(words.first.word, equals('Mutura'));
    });

    test('Excludes non-family-friendly cards when family friendly mode is active', () async {
      final words = await repo.getWordsForGame(
        categoryIds: [],
        difficulty: 'all',
        familyFriendlyOnly: true,
        isDrinkingMode: false,
      );

      expect(words.any((w) => w.isDrinking), isFalse);
      expect(words.length, equals(3));
    });
  });
}
