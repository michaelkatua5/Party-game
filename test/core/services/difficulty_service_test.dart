import 'package:flutter_test/flutter_test.dart';
// Note: We'll import relatively to make sure it works if package name differs
import 'package:cheza_game/domain/models/word_stats.dart';
import 'package:cheza_game/core/services/difficulty_service.dart';

void main() {
  group('DifficultyService Algorithm', () {
    test('New word starts at neutral difficulty 50', () {
      const stats = WordStats(wordId: 'test');
      expect(stats.difficultyScore, 50);
    });

    test('Score remains 50 if sample size < 10', () {
      WordStats stats = const WordStats(wordId: 'test');
      
      for (int i = 0; i < 9; i++) {
        stats = DifficultyService.recordOutcome(stats, WordOutcome.skipped, 2000);
      }
      
      expect(stats.timesShown, 9);
      expect(stats.difficultyScore, 50); // Locked until 10 plays
    });

    test('Successful fast guesses reduce difficulty', () {
      WordStats stats = const WordStats(wordId: 'test');
      
      // Simulate 25 very fast guesses (4 seconds each)
      for (int i = 0; i < 25; i++) {
        stats = DifficultyService.recordOutcome(stats, WordOutcome.guessed, 4000);
      }
      
      expect(stats.timesShown, 25);
      expect(stats.difficultyScore, lessThan(50));
      expect(stats.difficultyLevel, 'easy');
    });

    test('High skips increase difficulty', () {
      WordStats stats = const WordStats(wordId: 'test');
      
      // Simulate 25 skips
      for (int i = 0; i < 25; i++) {
        stats = DifficultyService.recordOutcome(stats, WordOutcome.skipped, 5000);
      }
      
      expect(stats.timesShown, 25);
      expect(stats.difficultyScore, greaterThan(50));
      expect(stats.difficultyLevel, 'hard');
    });

    test('Automatic flagging after 50 plays with >70% skips', () {
      WordStats stats = const WordStats(wordId: 'test');
      
      for (int i = 0; i < 50; i++) {
        // 80% skip rate
        if (i < 40) {
          stats = DifficultyService.recordOutcome(stats, WordOutcome.skipped, 2000);
        } else {
          stats = DifficultyService.recordOutcome(stats, WordOutcome.guessed, 10000);
        }
      }
      
      expect(stats.timesShown, 50);
      expect(stats.skipRate, 0.8);
      expect(stats.status, 'needs_review');
    });
  });
}
