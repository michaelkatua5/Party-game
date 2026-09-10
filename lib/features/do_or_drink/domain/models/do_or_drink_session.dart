import '../../../../domain/models/player.dart';

class DoOrDrinkSession {
  final List<Player> players;
  final String mode; // 'friendly', 'mild', 'spicy'
  final int currentPlayerIndex;
  final String? currentPrompt;

  DoOrDrinkSession({
    required this.players,
    required this.mode,
    this.currentPlayerIndex = 0,
    this.currentPrompt,
  });

  Player? get currentPlayer => players.isEmpty ? null : players[currentPlayerIndex];

  DoOrDrinkSession copyWith({
    List<Player>? players,
    String? mode,
    int? currentPlayerIndex,
    String? currentPrompt,
  }) {
    return DoOrDrinkSession(
      players: players ?? this.players,
      mode: mode ?? this.mode,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      currentPrompt: currentPrompt ?? this.currentPrompt,
    );
  }
}
