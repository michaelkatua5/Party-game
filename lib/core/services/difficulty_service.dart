import '../../domain/models/word_stats.dart';

enum WordOutcome {
  guessed,
  skipped,
  failed,
}

class DifficultyService {
  /// Base neutral score
  static const int baselineScore = 50;

  /// The bounds of difficulty
  static const int minScore = 0;
  static const int maxScore = 100;

  /// Recalculates the WordStats based on a new outcome.
  static WordStats recordOutcome(
    WordStats currentStats,
    WordOutcome outcome,
    int timeSpentMs,
  ) {
    // 1. Update Raw Stats
    final newShown = currentStats.timesShown + 1;
    final newGuessed = currentStats.timesGuessed + (outcome == WordOutcome.guessed ? 1 : 0);
    final newSkipped = currentStats.timesSkipped + (outcome == WordOutcome.skipped ? 1 : 0);
    final newFailed = currentStats.timesFailed + (outcome == WordOutcome.failed ? 1 : 0);
    
    // Only accumulate time if guessed correctly, to avoid skewing average with 1s skips
    // or full 60s failures.
    final newTotalTime = currentStats.totalTimeToGuessMs + 
        (outcome == WordOutcome.guessed ? timeSpentMs : 0);

    WordStats updated = currentStats.copyWith(
      timesShown: newShown,
      timesGuessed: newGuessed,
      timesSkipped: newSkipped,
      timesFailed: newFailed,
      totalTimeToGuessMs: newTotalTime,
    );

    // 2. Compute New Score
    final newScore = _calculateDifficultyScore(updated);
    updated = updated.copyWith(difficultyScore: newScore);

    // 3. Bad-word detection
    if (updated.timesShown >= 50 && updated.skipRate >= 0.70) {
      updated = updated.copyWith(status: 'needs_review');
    }

    return updated;
  }

  static int _calculateDifficultyScore(WordStats stats) {
    // If not enough data, return neutral
    if (stats.timesShown < 10) {
      return baselineScore;
    }

    double score = baselineScore.toDouble();

    // Calculate rates
    final skipRate = stats.skipRate; // 0.0 to 1.0
    final failRate = stats.failRate; // 0.0 to 1.0
    final successRate = stats.successRate; // 0.0 to 1.0
    final avgTimeSec = stats.averageTimeSeconds;

    // Weighting parameters
    // High skip rate increases difficulty heavily (up to +40)
    score += (skipRate * 40.0);

    // High failure rate increases difficulty (up to +30)
    score += (failRate * 30.0);

    // High success rate decreases difficulty (up to -30)
    score -= (successRate * 30.0);

    // Time factor
    // If avg time < 5s, it's very easy (reduce score)
    // If avg time > 15s, it's quite hard (increase score)
    if (successRate > 0) {
      if (avgTimeSec < 5.0) {
        score -= 10;
      } else if (avgTimeSec > 15.0) {
        score += 15;
      }
    }

    // Dampen changes if between 10 and 24 plays to avoid early extreme values
    if (stats.timesShown < 25) {
      score = baselineScore + ((score - baselineScore) * 0.5);
    }

    // Clamp score
    return score.round().clamp(minScore, maxScore);
  }
}
