class GameCategory {
  final String id;
  final String name;
  final String nameSw;
  final String description;
  final String icon;
  final String color;
  final bool isParty;
  final bool isFamilyFriendly;
  final int cardCount;

  const GameCategory({
    required this.id,
    required this.name,
    required this.nameSw,
    required this.description,
    required this.icon,
    required this.color,
    this.isParty = false,
    this.isFamilyFriendly = true,
    this.cardCount = 0,
  });

  factory GameCategory.fromJson(Map<String, dynamic> json, {int cardCount = 0}) {
    return GameCategory(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameSw: json['nameSw'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'grid',
      color: json['color'] as String? ?? '#FB8500',
      isParty: json['isParty'] as bool? ?? false,
      isFamilyFriendly: json['isFamilyFriendly'] as bool? ?? true,
      cardCount: cardCount,
    );
  }

  GameCategory copyWith({int? cardCount}) {
    return GameCategory(
      id: id,
      name: name,
      nameSw: nameSw,
      description: description,
      icon: icon,
      color: color,
      isParty: isParty,
      isFamilyFriendly: isFamilyFriendly,
      cardCount: cardCount ?? this.cardCount,
    );
  }
}
