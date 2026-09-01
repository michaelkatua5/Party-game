import 'package:flutter_test/flutter_test.dart';
import 'package:cheza_game/domain/models/game_session.dart';
import 'package:cheza_game/domain/models/game_settings.dart';
import 'package:cheza_game/domain/models/player.dart';
import 'package:cheza_game/domain/models/team.dart';
import 'package:cheza_game/domain/models/word.dart';

void main() {
  group('GameSession Domain Logic Tests', () {
    late GameSettings testSettings;
    late List<Team> testTeams;
    late List<GameWord> testDeck;

    setUp(() {
      testSettings = const GameSettings(
        roundDurationSeconds: 60,
        totalRounds: 3,
        difficulty: 'all',
        allowPassing: true,
        passPenalty: 0,
      );

      testTeams = [
        const Team(
          id: 'team_1',
          name: 'Team Simba',
          colorHex: '#FB8500',
          players: [Player(id: 'p1', name: 'Amina'), Player(id: 'p2', name: 'Juma')],
          score: 10,
        ),
        const Team(
          id: 'team_2',
          name: 'Team Chui',
          colorHex: '#06D6A0',
          players: [Player(id: 'p3', name: 'Kevin'), Player(id: 'p4', name: 'Wanjiku')],
          score: 15,
        ),
      ];

      testDeck = const [
        GameWord(id: 'w1', word: 'Mutura', categoryId: 'food', difficulty: 'easy'),
        GameWord(id: 'w2', word: 'Kula Fare', categoryId: 'sheng', difficulty: 'easy'),
        GameWord(id: 'w3', word: 'Rongai', categoryId: 'places', difficulty: 'easy'),
      ];
    });

    test('Winning team identifies the highest scoring team accurately', () {
      final session = GameSession(
        id: 'test_session_1',
        mode: GameMode.quickPlay,
        status: GameStatus.playing,
        settings: testSettings,
        teams: testTeams,
        wordDeck: testDeck,
        startedAt: DateTime.now(),
      );

      final winner = session.winningTeam;
      expect(winner, isNotNull);
      expect(winner!.id, equals('team_2'));
      expect(winner.score, equals(15));
      expect(winner.name, equals('Team Chui'));
    });

    test('Current word extraction returns active card correctly', () {
      final session = GameSession(
        id: 'test_session_2',
        mode: GameMode.quickPlay,
        status: GameStatus.playing,
        settings: testSettings,
        teams: testTeams,
        wordDeck: testDeck,
        currentWordIndex: 1,
        startedAt: DateTime.now(),
      );

      expect(session.currentWord, isNotNull);
      expect(session.currentWord!.id, equals('w2'));
      expect(session.currentWord!.word, equals('Kula Fare'));
    });

    test('Round calculation identifies when on last round', () {
      final session = GameSession(
        id: 'test_session_3',
        mode: GameMode.quickPlay,
        status: GameStatus.playing,
        settings: testSettings, // totalRounds = 3
        teams: testTeams,
        currentRound: 3,
        startedAt: DateTime.now(),
      );

      expect(session.isLastRound, isTrue);
    });
  });
}
