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
          ruleTitle: 'MEDUSA',
          ruleDescription: 'You are now Medusa! Anyone who makes eye contact with you must take a shot. You stay Medusa until the next Ace is drawn.',
          familyRuleDescription:
              'You are now Medusa! Anyone who makes eye contact with you must freeze for 5 seconds. You stay Medusa until the next Ace is drawn.',
          iconEmoji: '🐍',
        );
      case CardRank.two:
        return KingsCard(
          id: id,
          rank: rank,
          suit: suit,
          ruleTitle: 'YOU',
          ruleDescription: 'Choose someone to drink.',
          familyRuleDescription: 'Pick someone to do a silly dare or 10 jumping jacks.',
          iconEmoji: '👉',
        );
      case CardRank.three:
        return KingsCard(
          id: id,
          rank: rank,
          suit: suit,
          ruleTitle: 'ME',
          ruleDescription: 'You drink.',
          familyRuleDescription: 'You do a silly dance or sing a Kenyan song chorus!',
          iconEmoji: '🙋🏾‍♂️',
        );
      case CardRank.four:
        return KingsCard(
          id: id,
          rank: rank,
          suit: suit,
          ruleTitle: 'FLOOR',
          ruleDescription: 'The last person to touch the floor drinks.',
          familyRuleDescription: 'Everyone touch the floor! Last person to touch does 5 pushups.',
          iconEmoji: '👇',
        );
      case CardRank.five:
        return KingsCard(
          id: id,
          rank: rank,
          suit: suit,
          ruleTitle: 'GUYS',
          ruleDescription: 'Guys drink.',
          familyRuleDescription: 'All guys in the party must flex and strike a superhero pose!',
          iconEmoji: '👨‍👦‍👦',
        );
      case CardRank.six:
        return KingsCard(
          id: id,
          rank: rank,
          suit: suit,
          ruleTitle: 'CHICKS',
          ruleDescription: 'Girls drink.',
          familyRuleDescription: 'All ladies in the party do a celebratory victory twirl!',
          iconEmoji: '👯‍♀️',
        );
      case CardRank.seven:
        return KingsCard(
          id: id,
          rank: rank,
          suit: suit,
          ruleTitle: 'HEAVEN',
          ruleDescription: 'Raise your hand to heaven. The last person to do so drinks.',
          familyRuleDescription: 'Hands in the air! Last person to raise both hands gives a high-five to everyone.',
          iconEmoji: '🙌',
        );
      case CardRank.eight:
        return KingsCard(
          id: id,
          rank: rank,
          suit: suit,
          ruleTitle: 'MATE',
          ruleDescription: 'Choose someone to be your mate. Any time you drink, they drink.',
          familyRuleDescription: 'Choose a bestie! Whenever you have to do a challenge, your partner does it with you.',
          iconEmoji: '🤝',
        );
      case CardRank.nine:
        return KingsCard(
          id: id,
          rank: rank,
          suit: suit,
          ruleTitle: 'RHYME',
          ruleDescription: 'Say a word. The person to your right says a word that rhymes. The first person to fail drinks.',
          familyRuleDescription: 'Say a word. Everyone takes turns saying a rhyming word. First to get stuck loses a point!',
          iconEmoji: '🎤',
        );
      case CardRank.ten:
        return KingsCard(
          id: id,
          rank: rank,
          suit: suit,
          ruleTitle: 'CATEGORIES',
          ruleDescription: 'Choose a category of things. The person to your right names something in that category. The first person to fail drinks.',
          familyRuleDescription: 'Pick a category (e.g. African Animals, Nairobi Mtaas). Name items without repeating!',
          iconEmoji: '📚',
        );
      case CardRank.jack:
        return KingsCard(
          id: id,
          rank: rank,
          suit: suit,
          ruleTitle: 'NEVER HAVE I EVER',
          ruleDescription: 'Play never have I ever.',
          familyRuleDescription: 'Play Never Have I Ever with 3 fingers! First to lose all fingers does a funny dare.',
          iconEmoji: '🙈',
        );
      case CardRank.queen:
        return KingsCard(
          id: id,
          rank: rank,
          suit: suit,
          ruleTitle: 'QUESTION MASTER',
          ruleDescription: 'You are the Question Master! Ask anyone questions. If they answer, they take a shot. This lasts until the next Queen is drawn. To avoid drinking, they must ignore you.',
          familyRuleDescription: 'You are the Question Master! If you ask a question and someone answers, they lose a point. This lasts until the next Queen is drawn.',
          iconEmoji: '🧐',
        );
      case CardRank.king:
        return KingsCard(
          id: id,
          rank: rank,
          suit: suit,
          ruleTitle: 'KING\'S CUP',
          ruleDescription: 'Set a rule and pour some of your drink into the King\'s cup in the center of the table. Whoever draws the final King must drink the entire King\'s cup.',
          familyRuleDescription: 'Create a hilarious rule that lasts all game! (e.g. Must speak in accents or clap before speaking).',
          iconEmoji: '👑',
        );
    }
  }
}
