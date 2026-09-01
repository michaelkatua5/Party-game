import 'player.dart';

class Team {
  final String id;
  final String name;
  final String colorHex;
  final List<Player> players;
  final int score;
  final int correctCount;
  final int passCount;
  final int currentPlayerIndex;

  const Team({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.players,
    this.score = 0,
    this.correctCount = 0,
    this.passCount = 0,
    this.currentPlayerIndex = 0,
  });

  Player? get currentActer =>
      players.isNotEmpty ? players[currentPlayerIndex % players.length] : null;

  Team copyWith({
    String? name,
    String? colorHex,
    List<Player>? players,
    int? score,
    int? correctCount,
    int? passCount,
    int? currentPlayerIndex,
  }) {
    return Team(
      id: id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      players: players ?? this.players,
      score: score ?? this.score,
      correctCount: correctCount ?? this.correctCount,
      passCount: passCount ?? this.passCount,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
    );
  }
}
