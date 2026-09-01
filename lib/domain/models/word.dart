class GameWord {
  final String id;
  final String word;
  final String categoryId;
  final String difficulty; // easy, medium, hard
  final String language; // en, sw
  final List<String> aliases;
  final String hints;
  final String? hintSw;
  final bool familyFriendly;
  final bool isDrinking;
  final List<String> tags;

  const GameWord({
    required this.id,
    required this.word,
    required this.categoryId,
    required this.difficulty,
    this.language = 'en',
    this.aliases = const [],
    this.hints = '',
    this.hintSw,
    this.familyFriendly = true,
    this.isDrinking = false,
    this.tags = const [],
  });

  factory GameWord.fromJson(Map<String, dynamic> json) {
    return GameWord(
      id: json['id'] as String? ?? '',
      word: json['word'] as String? ?? '',
      categoryId: json['category'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'medium',
      language: json['language'] as String? ?? 'en',
      aliases: (json['aliases'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      hints: json['hints'] as String? ?? '',
      hintSw: json['hintSw'] as String?,
      familyFriendly: json['familyFriendly'] as bool? ?? true,
      isDrinking: json['isDrinking'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'word': word,
        'category': categoryId,
        'difficulty': difficulty,
        'language': language,
        'aliases': aliases,
        'hints': hints,
        'hintSw': hintSw,
        'familyFriendly': familyFriendly,
        'isDrinking': isDrinking,
        'tags': tags,
      };
}
