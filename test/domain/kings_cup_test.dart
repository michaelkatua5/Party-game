import 'package:flutter_test/flutter_test.dart';
import 'package:cheza_game/domain/models/kings_card.dart';
import 'package:cheza_game/domain/models/kings_cup_session.dart';
import 'package:cheza_game/domain/models/player.dart';

void main() {
  group('Kings Cup Engine Tests', () {
    test('Deck generator produces exactly 52 unique playing cards with 4 Kings', () {
      final deck = KingsCard.generateStandard52Deck();
      expect(deck.length, equals(52));

      final kings = deck.where((c) => c.isKing).toList();
      expect(kings.length, equals(4));

      final aces = deck.where((c) => c.rank == CardRank.ace).toList();
      expect(aces.length, equals(4));
      expect(aces.first.ruleTitle, equals('WATERFALL'));
    });

    test('All 13 Card ranks have valid rules matching blueprint specification', () {
      final deck = KingsCard.generateStandard52Deck();
      final rankMap = {for (var c in deck) c.rank: c};

      expect(rankMap[CardRank.ace]!.ruleTitle, equals('WATERFALL'));
      expect(rankMap[CardRank.two]!.ruleTitle, equals('YOU'));
      expect(rankMap[CardRank.three]!.ruleTitle, equals('ME'));
      expect(rankMap[CardRank.four]!.ruleTitle, equals('FLOOR'));
      expect(rankMap[CardRank.five]!.ruleTitle, equals('GUYS'));
      expect(rankMap[CardRank.six]!.ruleTitle, equals('CHICKS'));
      expect(rankMap[CardRank.seven]!.ruleTitle, equals('HEAVEN'));
      expect(rankMap[CardRank.eight]!.ruleTitle, equals('MATE'));
      expect(rankMap[CardRank.nine]!.ruleTitle, equals('RHYME'));
      expect(rankMap[CardRank.ten]!.ruleTitle, equals('CATEGORIES'));
      expect(rankMap[CardRank.jack]!.ruleTitle, equals('NEVER HAVE I EVER'));
      expect(rankMap[CardRank.queen]!.ruleTitle, equals('QUESTIONS'));
      expect(rankMap[CardRank.king]!.ruleTitle, equals('KING\'S CUP'));
    });

    test('New game starts with empty active rules (no fake default rules)', () {
      final session = KingsCupSession(
        id: 'test_session',
        deck: KingsCard.generateStandard52Deck(),
        players: const [Player(id: 'p1', name: 'Michael')],
      );

      expect(session.activeRules, isEmpty);
      expect(session.kingsDrawnCount, equals(0));
      expect(session.isFinalKing, isFalse);
    });

    test('Kings Cup session accurately counts Kings and triggers final King state', () {
      final deck = KingsCard.generateStandard52Deck();
      final kingCard = deck.firstWhere((c) => c.isKing);

      final session = KingsCupSession(
        id: 'kc_test',
        deck: deck,
        drawnStack: [kingCard, kingCard, kingCard],
        currentRevealedCard: kingCard,
        players: const [Player(id: 'p1', name: 'Michael')],
      );

      expect(session.kingsDrawnCount, equals(4));
      expect(session.isFinalKing, isTrue);
    });
  });
}
