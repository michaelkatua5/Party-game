class Player {
  final String id;
  final String name;
  final String? avatar;
  final int totalCorrect;
  final int totalPassed;

  const Player({
    required this.id,
    required this.name,
    this.avatar,
    this.totalCorrect = 0,
    this.totalPassed = 0,
  });

  Player copyWith({
    String? name,
    String? avatar,
    int? totalCorrect,
    int? totalPassed,
  }) {
    return Player(
      id: id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalPassed: totalPassed ?? this.totalPassed,
    );
  }
}
