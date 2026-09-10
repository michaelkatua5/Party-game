class WordStats {
  final String wordId;
  final int timesShown;
  final int timesGuessed;
  final int timesSkipped;
  final int timesFailed;
  final int totalTimeToGuessMs;
  final int difficultyScore;
  final String status; // 'active', 'needs_review', 'inactive'

  const WordStats({
    required this.wordId,
    this.timesShown = 0,
    this.timesGuessed = 0,
    this.timesSkipped = 0,
    this.timesFailed = 0,
    this.totalTimeToGuessMs = 0,
    this.difficultyScore = 50,
    this.status = 'active',
  });

  double get skipRate => timesShown > 0 ? timesSkipped / timesShown : 0.0;
  double get failRate => timesShown > 0 ? timesFailed / timesShown : 0.0;
  double get successRate => timesShown > 0 ? timesGuessed / timesShown : 0.0;
  
  double get averageTimeSeconds => timesGuessed > 0 
      ? (totalTimeToGuessMs / timesGuessed) / 1000.0 
      : 0.0;

  String get difficultyLevel {
    if (difficultyScore < 40) return 'easy';
    if (difficultyScore < 70) return 'medium';
    return 'hard';
  }

  factory WordStats.fromJson(Map<String, dynamic> json) {
    return WordStats(
      wordId: json['word_id'] as String,
      timesShown: json['times_shown'] as int? ?? 0,
      timesGuessed: json['times_guessed'] as int? ?? 0,
      timesSkipped: json['times_skipped'] as int? ?? 0,
      timesFailed: json['times_failed'] as int? ?? 0,
      totalTimeToGuessMs: json['total_time_to_guess_ms'] as int? ?? 0,
      difficultyScore: json['difficulty_score'] as int? ?? 50,
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() => {
        'word_id': wordId,
        'times_shown': timesShown,
        'times_guessed': timesGuessed,
        'times_skipped': timesSkipped,
        'times_failed': timesFailed,
        'total_time_to_guess_ms': totalTimeToGuessMs,
        'difficulty_score': difficultyScore,
        'status': status,
      };

  WordStats copyWith({
    String? wordId,
    int? timesShown,
    int? timesGuessed,
    int? timesSkipped,
    int? timesFailed,
    int? totalTimeToGuessMs,
    int? difficultyScore,
    String? status,
  }) {
    return WordStats(
      wordId: wordId ?? this.wordId,
      timesShown: timesShown ?? this.timesShown,
      timesGuessed: timesGuessed ?? this.timesGuessed,
      timesSkipped: timesSkipped ?? this.timesSkipped,
      timesFailed: timesFailed ?? this.timesFailed,
      totalTimeToGuessMs: totalTimeToGuessMs ?? this.totalTimeToGuessMs,
      difficultyScore: difficultyScore ?? this.difficultyScore,
      status: status ?? this.status,
    );
  }
}
