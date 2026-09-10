import 'word.dart';
import 'team.dart';
import 'game_settings.dart';

enum GameStatus {
  idle,
  countingDown,
  playing,
  paused,
  roundTransition,
  completed,
}

enum GameMode {
  quickPlay,
  customTeams,
  soloPractice,
}

class GameSession {
  final String id;
  final GameMode mode;
  final GameStatus status;
  final GameSettings settings;
  final List<Team> teams;
  final int currentTeamIndex;
  final int currentRound;
  final List<GameWord> wordDeck;
  final int currentWordIndex;
  final List<String> answeredWordIds;
  final List<String> passedWordIds;
  final int currentStreak;
  final int bestStreak;
  final DateTime startedAt;

  const GameSession({
    required this.id,
    required this.mode,
    required this.status,
    required this.settings,
    required this.teams,
    this.currentTeamIndex = 0,
    this.currentRound = 1,
    this.wordDeck = const [],
    this.currentWordIndex = 0,
    this.answeredWordIds = const [],
    this.passedWordIds = const [],
    this.currentStreak = 0,
    this.bestStreak = 0,
    required this.startedAt,
  });

  Team get currentTeam => teams.isNotEmpty
      ? teams[currentTeamIndex % teams.length]
      : const Team(id: 't1', name: 'Team Simba', colorHex: '#FB8500', players: []);

  Team get nextTeam => teams.isNotEmpty
      ? teams[(currentTeamIndex + 1) % teams.length]
      : const Team(id: 't2', name: 'Team Chui', colorHex: '#06D6A0', players: []);

  GameWord? get currentWord {
    if (wordDeck.isEmpty || currentWordIndex >= wordDeck.length) return null;
    return wordDeck[currentWordIndex];
  }

  bool get isLastRound => currentRound >= settings.totalRounds;

  Team? get winningTeam {
    if (teams.isEmpty) return null;
    final sorted = List<Team>.from(teams)..sort((a, b) => b.score.compareTo(a.score));
    return sorted.first;
  }

  GameSession copyWith({
    GameMode? mode,
    GameStatus? status,
    GameSettings? settings,
    List<Team>? teams,
    int? currentTeamIndex,
    int? currentRound,
    List<GameWord>? wordDeck,
    int? currentWordIndex,
    List<String>? answeredWordIds,
    List<String>? passedWordIds,
    int? currentStreak,
    int? bestStreak,
    DateTime? startedAt,
  }) {
    return GameSession(
      id: id,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      settings: settings ?? this.settings,
      teams: teams ?? this.teams,
      currentTeamIndex: currentTeamIndex ?? this.currentTeamIndex,
      currentRound: currentRound ?? this.currentRound,
      wordDeck: wordDeck ?? this.wordDeck,
      currentWordIndex: currentWordIndex ?? this.currentWordIndex,
      answeredWordIds: answeredWordIds ?? this.answeredWordIds,
      passedWordIds: passedWordIds ?? this.passedWordIds,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      startedAt: startedAt ?? this.startedAt,
    );
  }
}
