class GameStats {
  final int totalGamesPlayed;
  final int totalGamesWon;
  final int totalWordsAnswered;
  final int totalWordsPassed;
  final int longestStreak;
  final String favoriteCategory;

  const GameStats({
    this.totalGamesPlayed = 0,
    this.totalGamesWon = 0,
    this.totalWordsAnswered = 0,
    this.totalWordsPassed = 0,
    this.longestStreak = 0,
    this.favoriteCategory = 'sheng',
  });

  double get winRate =>
      totalGamesPlayed > 0 ? (totalGamesWon / totalGamesPlayed) * 100 : 0.0;

  double get accuracy => (totalWordsAnswered + totalWordsPassed) > 0
      ? (totalWordsAnswered / (totalWordsAnswered + totalWordsPassed)) * 100
      : 0.0;

  factory GameStats.fromJson(Map<String, dynamic> json) {
    return GameStats(
      totalGamesPlayed: json['totalGamesPlayed'] as int? ?? 0,
      totalGamesWon: json['totalGamesWon'] as int? ?? 0,
      totalWordsAnswered: json['totalWordsAnswered'] as int? ?? 0,
      totalWordsPassed: json['totalWordsPassed'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      favoriteCategory: json['favoriteCategory'] as String? ?? 'sheng',
    );
  }

  Map<String, dynamic> toJson() => {
        'totalGamesPlayed': totalGamesPlayed,
        'totalGamesWon': totalGamesWon,
        'totalWordsAnswered': totalWordsAnswered,
        'totalWordsPassed': totalWordsPassed,
        'longestStreak': longestStreak,
        'favoriteCategory': favoriteCategory,
      };
}
