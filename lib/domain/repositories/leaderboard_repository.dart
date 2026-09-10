class LeaderboardEntry {
  final String id;
  final String teamOrPlayerName;
  final int score;
  final int gamesWon;
  final double accuracy;
  final DateTime date;
  final String? avatar;

  const LeaderboardEntry({
    required this.id,
    required this.teamOrPlayerName,
    required this.score,
    required this.gamesWon,
    required this.accuracy,
    required this.date,
    this.avatar,
  });

  String get playerName => teamOrPlayerName;

  Map<String, dynamic> toJson() => {
        'id': id,
        'teamOrPlayerName': teamOrPlayerName,
        'score': score,
        'gamesWon': gamesWon,
        'accuracy': accuracy,
        'date': date.toIso8601String(),
        'avatar': avatar,
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
        id: json['id'] as String? ?? '',
        teamOrPlayerName: json['teamOrPlayerName'] as String? ?? 'Team',
        score: json['score'] as int? ?? 0,
        gamesWon: json['gamesWon'] as int? ?? 0,
        accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
        date: json['date'] != null
            ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
            : DateTime.now(),
        avatar: json['avatar'] as String?,
      );
}

abstract class LeaderboardRepository {
  Future<List<LeaderboardEntry>> getLocalLeaderboard();
  Future<void> addLeaderboardEntry(LeaderboardEntry entry);
}
