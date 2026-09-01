enum CardSuit { hearts, diamonds, clubs, spades }

enum CardRank {
  ace,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king,
}

class KingsCard {
  final String id;
  final CardRank rank;
  final CardSuit suit;
  final String ruleTitle;
  final String ruleDescription;
  final String familyRuleDescription;
  final String iconEmoji;

  const KingsCard({
    required this.id,
    required this.rank,
    required this.suit,
    required this.ruleTitle,
    required this.ruleDescription,
    required this.familyRuleDescription,
    required this.iconEmoji,
  });

  bool get isKing => rank == CardRank.king;

  String get rankDisplay {
    switch (rank) {
      case CardRank.ace:
        return 'A';
      case CardRank.two:
        return '2';
      case CardRank.three:
        return '3';
      case CardRank.four:
        return '4';
      case CardRank.five:
        return '5';
      case CardRank.six:
        return '6';
      case CardRank.seven:
        return '7';
      case CardRank.eight:
        return '8';
      case CardRank.nine:
        return '9';
      case CardRank.ten:
        return '10';
      case CardRank.jack:
        return 'J';
      case CardRank.queen:
        return 'Q';
      case CardRank.king:
        return 'K';
    }
  }

  String get suitSymbol {
    switch (suit) {
      case CardSuit.hearts:
        return '♥';
      case CardSuit.diamonds:
        return '♦';
      case CardSuit.clubs:
        return '♣';
      case CardSuit.spades:
        return '♠';
    }
  }

  bool get isRed => suit == CardSuit.hearts || suit == CardSuit.diamonds;

  static List<KingsCard> generateStandard52Deck() {
    final List<KingsCard> deck = [];

    for (final suit in CardSuit.values) {
      for (final rank in CardRank.values) {
        deck.add(_createCard(suit, rank));
      }
    }

    return deck;
  }

  static KingsCard _createCard(CardSuit suit, CardRank rank) {
    final id = '${rank.name}_${suit.name}';

    switch (rank) {
      case CardRank.ace:
        return KingsCard(
          id: id,
          rank: rank,
          suit: suit,
          ruleTitle: 'WATERFALL',
          ruleDescription:
              'Start drinking at the same time as the person to your left. Nobody stops until the person before them stops!',
          familyRuleDescription:
              'Start clapping or humming at the same time as the person to your left. Keep going in a continuous wave!',
          iconEmoji: '🌊',
        );
      case CardRank.two:
        return KingsCard(
          id: id,
          rank: rank,
          suit: suit,
          ruleTitle: 'YOU',
          ruleDescription: 'Pick someone else in the room to take a sip / penalty.',
          familyRuleDescription: 'Pick someone to do a silly dare or 10 jumping jacks.',
          iconEmoji: '👉',
        );
      case CardRank.three:
        return KingsCard(
          id: id,
          rank: rank,
          suit: suit,
          ruleTitle: 'ME',
          ruleDescription: 'You take a drink / sip yourself!',
          familyRuleDescription: 'You do a silly dance or sing a Kenyan song chorus!',
          iconEmoji: '🙋🏾‍♂️',
        );
      case CardRank.four:
        return KingsCard(
          id: id,
          rank: rank,
          suit: suit,
          ruleTitle: 'FLOOR',
          ruleDescription: 'Everyone must quickly touch the floor. Last person to touch the floor drinks!',
          familyRuleDescription: 'Everyone touch the floor! Last person to touch does 5 pushups.',
          iconEmoji: '👇',
        );
      case CardRank.five:
        return KingsCard(
          id: id,
          rank: rank,
          suit: suit,
          ruleTitle: 'GUYS',
          ruleDescription: 'All guys in the party take a drink!',
          familyRuleDescription: 'All guys in the party must flex and strike a superhero pose!',
          iconEmoji: '👨‍👦‍👦',
        );
      case CardRank.six:
        return KingsCard(
          id: id,
          rank: rank,
          suit: suit,
          ruleTitle: 'CHICKS',
          ruleDescription: 'All ladies in the party take a drink!',
          familyRuleDescription: 'All ladies in the party do a celebratory victory twirl!',
          iconEmoji: '👯‍♀️',
        );
      case CardRank.seven:
        return KingsCard(
          id: id,
          rank: rank,
          suit: suit,
          ruleTitle: 'HEAVEN',
          ruleDescription: 'Raise your hands into the air! Last person to point up to heaven drinks.',
          familyRuleDescription: 'Hands in the air! Last person to raise both hands gives a high-five to everyone.',
          iconEmoji: '🙌',
        );
      case CardRank.eight:
        return KingsCard(
          id: id,
          rank: rank,
          suit: suit,
          ruleTitle: 'MATE',
          ruleDescription: 'Choose a drinking mate. Whenever you have to drink for the rest of the game, your mate must drink too!',
          familyRuleDescription: 'Choose a bestie! Whenever you have to do a challenge, your partner does it with you.',
          iconEmoji: '🤝',
        );
      case CardRank.nine:
        return KingsCard(
          id: id,
          rank: rank,
          suit: suit,
          ruleTitle: 'RHYME',
          ruleDescription: 'Say a word. Going clockwise, each player must say a rhyming word. First player to hesitate or repeat drinks!',
          familyRuleDescription: 'Say a word. Everyone takes turns saying a rhyming word. First to get stuck loses a point!',
          iconEmoji: '🎤',
        );
      case CardRank.ten:
        return KingsCard(
          id: id,
          rank: rank,
          suit: suit,
          ruleTitle: 'CATEGORIES',
          ruleDescription: 'Pick a category (e.g. Kenyan Foods, Matatu Routes). Going clockwise, each player names an item. First to fail drinks!',
          familyRuleDescription: 'Pick a category (e.g. African Animals, Nairobi Mtaas). Name items without repeating!',
          iconEmoji: '📚',
        );
      case CardRank.jack:
        return KingsCard(
          id: id,
          rank: rank,
          suit: suit,
          ruleTitle: 'NEVER HAVE I EVER',
          ruleDescription: 'Everyone puts up 3 fingers. Take turns saying something you\'ve never done. Anyone who has done it puts a finger down. First with 0 fingers drinks!',
          familyRuleDescription: 'Play Never Have I Ever with 3 fingers! First to lose all fingers does a funny dare.',
          iconEmoji: '🙈',
        );
      case CardRank.queen:
        return KingsCard(
          id: id,
          rank: rank,
          suit: suit,
          ruleTitle: 'QUESTIONS',
          ruleDescription: 'Ask someone a question without answering. They must immediately ask someone else a question. First to answer or hesitate drinks!',
          familyRuleDescription: 'Rapid fire question chain! You cannot answer, only ask a new question.',
          iconEmoji: '❓',
        );
      case CardRank.king:
        return KingsCard(
          id: id,
          rank: rank,
          suit: suit,
          ruleTitle: 'KING\'S CUP',
          ruleDescription: 'Make a new party rule that everyone must follow! Pour some of your drink into the center King\'s Cup. (Whoever draws the 4th King drinks the entire cup!)',
          familyRuleDescription: 'Create a hilarious rule that lasts all game! (e.g. Must speak in accents or clap before speaking).',
          iconEmoji: '👑',
        );
    }
  }
}
