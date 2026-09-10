import 'kings_card.dart';
import 'player.dart';

class KingsCupSession {
  final String id;
  final List<KingsCard> deck;
  final List<KingsCard> drawnStack;
  final List<Player> players;
  final int currentPlayerIndex;
  final List<String> activeRules;
  final Map<String, String> matesMap; // playerId -> matePlayerId
  final bool isFamilyMode;
  final KingsCard? currentRevealedCard;
  final bool isGameOver;

  const KingsCupSession({
    required this.id,
    required this.deck,
    this.drawnStack = const [],
    required this.players,
    this.currentPlayerIndex = 0,
    this.activeRules = const [], // Starts empty! Real custom rules are added dynamically
    this.matesMap = const {},
    this.isFamilyMode = false,
    this.currentRevealedCard,
    this.isGameOver = false,
  });

  /// Total count of Kings drawn so far in this game (max 4)
  int get kingsDrawnCount {
    final drawnKings = drawnStack.where((c) => c.isKing).length;
    final currentIsKing = currentRevealedCard?.isKing == true ? 1 : 0;
    return drawnKings + currentIsKing;
  }

  bool get isFinalKing => kingsDrawnCount >= 4;

  int get cardsRemaining => deck.length;

  Player get currentPlayer =>
      players.isNotEmpty ? players[currentPlayerIndex % players.length] : const Player(id: 'p1', name: 'Player 1');

  String get currentTurnPlayerName => currentPlayer.name;

  KingsCupSession copyWith({
    List<KingsCard>? deck,
    List<KingsCard>? drawnStack,
    List<Player>? players,
    int? currentPlayerIndex,
    List<String>? activeRules,
    Map<String, String>? matesMap,
    bool? isFamilyMode,
    KingsCard? currentRevealedCard,
    bool clearCurrentRevealedCard = false,
    bool? isGameOver,
  }) {
    return KingsCupSession(
      id: id,
      deck: deck ?? this.deck,
      drawnStack: drawnStack ?? this.drawnStack,
      players: players ?? this.players,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      activeRules: activeRules ?? this.activeRules,
      matesMap: matesMap ?? this.matesMap,
      isFamilyMode: isFamilyMode ?? this.isFamilyMode,
      currentRevealedCard: clearCurrentRevealedCard ? null : (currentRevealedCard ?? this.currentRevealedCard),
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }
}
