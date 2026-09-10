import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/haptic_service.dart';
import '../../../domain/models/game_session.dart';
import '../../../domain/models/game_settings.dart';
import '../../../domain/models/player.dart';
import '../../../domain/models/team.dart';
import '../../../domain/models/word.dart';
import '../../../domain/repositories/leaderboard_repository.dart';
import '../../../data/repositories/word_stats_repository.dart';
import '../../../domain/models/word_stats.dart';
import '../../../core/services/difficulty_service.dart';
import 'timer_controller.dart';

final gameControllerProvider =
    StateNotifierProvider<GameControllerNotifier, GameSession?>((ref) {
  return GameControllerNotifier(ref);
});

class GameControllerNotifier extends StateNotifier<GameSession?> {
  final Ref ref;
  DateTime? _wordStartTime;
  
  // Collect outcomes to batch write at the end of the round
  final List<Map<String, dynamic>> _roundOutcomes = [];

  GameControllerNotifier(this.ref) : super(null);

  AudioService get _audio => ref.read(audioServiceProvider);
  HapticService get _haptic => ref.read(hapticServiceProvider);

  Future<void> startQuickPlay() async {
    final wordRepo = ref.read(wordRepositoryProvider);
    const settings = GameSettings(
      roundDurationSeconds: 60,
      totalRounds: 3,
      difficulty: 'all',
      selectedCategoryIds: [],
      familyFriendlyMode: true,
      drinkingMode: false,
    );

    final words = await wordRepo.getWordsForGame(
      categoryIds: [],
      difficulty: 'all',
      familyFriendlyOnly: true,
      isDrinkingMode: false,
    );

    final shuffled = List<GameWord>.from(words)..shuffle(Random());

    final defaultTeams = [
      const Team(
        id: 'team_1',
        name: 'Team Simba',
        colorHex: '#FB8500',
        players: [Player(id: 'p1', name: 'Player 1'), Player(id: 'p2', name: 'Player 2')],
      ),
      const Team(
        id: 'team_2',
        name: 'Team Chui',
        colorHex: '#06D6A0',
        players: [Player(id: 'p3', name: 'Player 3'), Player(id: 'p4', name: 'Player 4')],
      ),
    ];

    state = GameSession(
      id: const Uuid().v4(),
      mode: GameMode.quickPlay,
      status: GameStatus.countingDown,
      settings: settings,
      teams: defaultTeams,
      wordDeck: shuffled,
      startedAt: DateTime.now(),
    );

    _logGameStart();
  }

  Future<void> startCustomGame({
    required GameSettings settings,
    required List<Team> teams,
  }) async {
    final wordRepo = ref.read(wordRepositoryProvider);
    final words = await wordRepo.getWordsForGame(
      categoryIds: settings.selectedCategoryIds,
      difficulty: settings.difficulty,
      familyFriendlyOnly: settings.familyFriendlyMode,
      isDrinkingMode: settings.drinkingMode,
    );

    final balancedDeck = _balanceDeck(words);

    state = GameSession(
      id: const Uuid().v4(),
      mode: GameMode.customTeams,
      status: GameStatus.countingDown,
      settings: settings,
      teams: teams,
      wordDeck: balancedDeck,
      startedAt: DateTime.now(),
    );

    _logGameStart();
  }

  List<GameWord> _balanceDeck(List<GameWord> words) {
    if (words.isEmpty) return words;
    final Map<String, List<GameWord>> byCategory = {};
    for (final w in words) {
      byCategory.putIfAbsent(w.categoryId, () => []).add(w);
    }
    final rnd = Random();
    for (final list in byCategory.values) {
      list.shuffle(rnd);
    }

    final List<GameWord> result = [];
    bool hasMore = true;
    int index = 0;
    while (hasMore) {
      hasMore = false;
      for (final list in byCategory.values) {
        if (index < list.length) {
          result.add(list[index]);
          hasMore = true;
        }
      }
      index++;
    }
    return result.isEmpty ? (List<GameWord>.from(words)..shuffle(rnd)) : result;
  }

  Future<void> startTurnWithCategory(String categoryId) async {
    final wordRepo = ref.read(wordRepositoryProvider);
    final settings = state?.settings ?? const GameSettings();
    final allWords = await wordRepo.getWordsForGame(
      categoryIds: [categoryId],
      difficulty: settings.difficulty,
      familyFriendlyOnly: settings.familyFriendlyMode,
      isDrinkingMode: settings.drinkingMode,
    );

    final usedWordIds = state != null ? {...state!.answeredWordIds, ...state!.passedWordIds} : <String>{};
    var available = allWords.where((w) => !usedWordIds.contains(w.id)).toList();
    if (available.isEmpty) {
      available = List<GameWord>.from(allWords);
    }
    available.shuffle(Random());

    final updatedSettings = settings.copyWith(
      selectedCategoryIds: [categoryId],
    );

    if (state == null) {
      final defaultTeams = [
        const Team(
          id: 'team_1',
          name: 'Team Simba',
          colorHex: '#FFB800',
          players: [Player(id: 'p1', name: 'Player 1'), Player(id: 'p2', name: 'Player 2')],
        ),
        const Team(
          id: 'team_2',
          name: 'Team Chui',
          colorHex: '#00F0FF',
          players: [Player(id: 'p3', name: 'Player 3'), Player(id: 'p4', name: 'Player 4')],
        ),
      ];
      state = GameSession(
        id: const Uuid().v4(),
        mode: GameMode.quickPlay,
        status: GameStatus.countingDown,
        settings: updatedSettings,
        teams: defaultTeams,
        wordDeck: available,
        startedAt: DateTime.now(),
      );
      _logGameStart();
    } else {
      state = state!.copyWith(
        settings: updatedSettings,
        wordDeck: available,
        currentWordIndex: 0,
        status: GameStatus.countingDown,
      );
    }
  }

  void startNextRound() {
    proceedToNextTurn();
  }

  void beginActiveTurn() {
    if (state == null) return;
    state = state!.copyWith(status: GameStatus.playing);
    _wordStartTime = DateTime.now();
    _roundOutcomes.clear();

    ref.read(timerNotifierProvider.notifier).startTimer(
          durationSeconds: state!.settings.roundDurationSeconds,
          onCompleted: () => onTimeUp(),
          onSecondTick: (remaining) {
            if (remaining <= 5 && remaining > 0) {
              _audio.play(GameSound.countdownTick);
              _haptic.trigger(HapticType.warning);
            }
          },
        );
  }

  void _recordOutcome(String wordId, WordOutcome outcome) {
    if (_wordStartTime != null) {
      final timeSpentMs = DateTime.now().difference(_wordStartTime!).inMilliseconds;
      _roundOutcomes.add({
        'wordId': wordId,
        'outcome': outcome,
        'timeSpentMs': timeSpentMs,
      });
      _wordStartTime = DateTime.now(); // reset for next word
    }
  }

  void onCorrect() {
    if (state == null || state!.status != GameStatus.playing) return;

    final session = state!;
    final currentWord = session.currentWord;
    if (currentWord == null) return;

    _recordOutcome(currentWord.id, WordOutcome.guessed);

    _audio.play(GameSound.correct);
    _haptic.trigger(HapticType.success);

    // Update Team score
    final currentTeam = session.currentTeam;
    final updatedTeam = currentTeam.copyWith(
      score: currentTeam.score + session.settings.passPenalty == 0
          ? currentTeam.score + 1
          : currentTeam.score + 1,
      correctCount: currentTeam.correctCount + 1,
    );

    final updatedTeams = List<Team>.from(session.teams);
    updatedTeams[session.currentTeamIndex % updatedTeams.length] = updatedTeam;

    final newStreak = session.currentStreak + 1;
    final bestStreak = max(session.bestStreak, newStreak);

    state = session.copyWith(
      teams: updatedTeams,
      currentWordIndex: session.currentWordIndex + 1,
      answeredWordIds: [...session.answeredWordIds, currentWord.id],
      currentStreak: newStreak,
      bestStreak: bestStreak,
    );

    ref.read(analyticsServiceProvider).logWordAnswered(
          wordId: currentWord.id,
          categoryId: currentWord.categoryId,
          correct: true,
        );
  }

  void onPass() {
    if (state == null || state!.status != GameStatus.playing) return;

    final session = state!;
    final currentWord = session.currentWord;
    if (currentWord == null) return;

    _recordOutcome(currentWord.id, WordOutcome.skipped);

    _audio.play(GameSound.pass);
    _haptic.trigger(HapticType.medium);

    // If pass penalty applies
    final currentTeam = session.currentTeam;
    final newScore = max(0, currentTeam.score + session.settings.passPenalty);
    final updatedTeam = currentTeam.copyWith(
      score: newScore,
      passCount: currentTeam.passCount + 1,
    );

    final updatedTeams = List<Team>.from(session.teams);
    updatedTeams[session.currentTeamIndex % updatedTeams.length] = updatedTeam;

    state = session.copyWith(
      teams: updatedTeams,
      currentWordIndex: session.currentWordIndex + 1,
      passedWordIds: [...session.passedWordIds, currentWord.id],
      currentStreak: 0,
    );

    ref.read(analyticsServiceProvider).logWordAnswered(
          wordId: currentWord.id,
          categoryId: currentWord.categoryId,
          correct: false,
        );
  }

  void onWrong() {
    if (state == null || state!.status != GameStatus.playing) return;

    final session = state!;
    final currentWord = session.currentWord;
    if (currentWord == null) return;

    _recordOutcome(currentWord.id, WordOutcome.failed);

    _audio.play(GameSound.wrong);
    _haptic.trigger(HapticType.error);

    state = session.copyWith(
      currentWordIndex: session.currentWordIndex + 1,
      passedWordIds: [...session.passedWordIds, currentWord.id],
      currentStreak: 0,
    );
  }

  void pauseGame() {
    if (state == null || state!.status != GameStatus.playing) return;
    ref.read(timerNotifierProvider.notifier).pauseTimer();
    state = state!.copyWith(status: GameStatus.paused);
  }

  void resumeGame() {
    if (state == null || state!.status != GameStatus.paused) return;
    ref.read(timerNotifierProvider.notifier).resumeTimer();
    state = state!.copyWith(status: GameStatus.playing);
  }

  void onTimeUp() {
    if (state == null) return;

    _audio.play(GameSound.timeUp);
    _haptic.trigger(HapticType.heavy);

    final session = state!;
    
    // Record the final word if time ran out while it was on screen
    if (session.currentWord != null && session.status == GameStatus.playing) {
      _recordOutcome(session.currentWord!.id, WordOutcome.failed);
    }
    
    // Batch save stats
    _saveRoundOutcomes();

    final nextTeamIndex = session.currentTeamIndex + 1;
    final isRoundComplete = (nextTeamIndex % session.teams.length) == 0;
    final nextRound = isRoundComplete ? session.currentRound + 1 : session.currentRound;

    if (isRoundComplete && session.currentRound >= session.settings.totalRounds) {
      // Game completely finished
      finishGame();
    } else {
      // Rotate active player inside the current team
      final currentTeam = session.currentTeam;
      final rotatedTeam = currentTeam.copyWith(
        currentPlayerIndex: currentTeam.currentPlayerIndex + 1,
      );
      final updatedTeams = List<Team>.from(session.teams);
      updatedTeams[session.currentTeamIndex % updatedTeams.length] = rotatedTeam;

      state = session.copyWith(
        status: GameStatus.roundTransition,
        teams: updatedTeams,
        currentTeamIndex: nextTeamIndex,
        currentRound: nextRound,
        currentStreak: 0,
      );
    }
  }
  
  Future<void> _saveRoundOutcomes() async {
    if (_roundOutcomes.isEmpty) return;
    final statsRepo = ref.read(wordStatsRepositoryProvider);
    
    // We must read the existing stats first, then update them.
    final List<WordStats> updatedStats = [];
    for (final outcomeData in _roundOutcomes) {
      final wordId = outcomeData['wordId'] as String;
      final outcome = outcomeData['outcome'] as WordOutcome;
      final timeSpentMs = outcomeData['timeSpentMs'] as int;
      
      final current = await statsRepo.getStatsForWord(wordId);
      final updated = DifficultyService.recordOutcome(current, outcome, timeSpentMs);
      updatedStats.add(updated);
    }
    
    await statsRepo.saveBatchStats(updatedStats);
    _roundOutcomes.clear();
  }

  void selectTeamIndex(int index) {
    if (state == null || state!.teams.isEmpty) return;
    final validIndex = index % state!.teams.length;
    state = state!.copyWith(currentTeamIndex: validIndex);
  }

  void setTeams(List<Team> newTeams) {
    if (state == null || newTeams.isEmpty) return;
    state = state!.copyWith(teams: newTeams);
  }

  void proceedToNextTurn() {
    if (state == null) return;
    state = state!.copyWith(status: GameStatus.countingDown);
  }

  Future<void> finishGame() async {
    if (state == null) return;

    _audio.play(GameSound.victoryFanfare);
    _haptic.trigger(HapticType.success);

    final session = state!;
    state = session.copyWith(status: GameStatus.completed);

    final winning = session.winningTeam;
    final statsRepo = ref.read(statsRepositoryProvider);
    final leaderboardRepo = ref.read(leaderboardRepositoryProvider);

    if (winning != null) {
      await statsRepo.updateGameEnded(
        won: true,
        correctAnswers: session.answeredWordIds.length,
        passedAnswers: session.passedWordIds.length,
        streak: session.bestStreak,
        categoryId: session.settings.selectedCategoryIds.isNotEmpty
            ? session.settings.selectedCategoryIds.first
            : 'mixed',
      );

      await leaderboardRepo.addLeaderboardEntry(
        LeaderboardEntry(
          id: const Uuid().v4(),
          teamOrPlayerName: winning.name,
          score: winning.score,
          gamesWon: 1,
          accuracy: (winning.correctCount + winning.passCount) > 0
              ? (winning.correctCount / (winning.correctCount + winning.passCount)) * 100
              : 100.0,
          date: DateTime.now(),
        ),
      );
    }

    ref.read(analyticsServiceProvider).logGameCompleted(
          mode: session.mode.name,
          durationSeconds: DateTime.now().difference(session.startedAt).inSeconds,
          totalWordsAnswered: session.answeredWordIds.length,
          winningScore: winning?.score ?? 0,
        );
  }

  void restartGame() {
    if (state == null) return;
    final current = state!;
    startCustomGame(
      settings: current.settings,
      teams: current.teams.map((t) => t.copyWith(score: 0, correctCount: 0, passCount: 0)).toList(),
    );
  }

  void resetGame() {
    ref.read(timerNotifierProvider.notifier).stopTimer();
    state = null;
  }

  void _logGameStart() {
    if (state == null) return;
    ref.read(analyticsServiceProvider).logGameStarted(
          mode: state!.mode.name,
          playerCount: state!.teams.fold(0, (acc, t) => acc + t.players.length),
          teamCount: state!.teams.length,
          categories: state!.settings.selectedCategoryIds,
        );
  }
}
