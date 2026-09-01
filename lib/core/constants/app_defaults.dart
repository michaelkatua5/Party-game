class AppDefaults {
  static const int defaultRoundDurationSeconds = 60;
  static const int minRoundDurationSeconds = 30;
  static const int maxRoundDurationSeconds = 120;
  static const int defaultRoundsCount = 3;
  static const int minRoundsCount = 1;
  static const int maxRoundsCount = 10;

  static const int defaultPointsPerCorrect = 1;
  static const int defaultPassPenalty = 0; // 0 or -1

  static const List<String> defaultTeamNames = [
    'Team Simba',
    'Team Chui',
    'Team Ndovu',
    'Team Kifaru',
  ];

  static const List<String> defaultTeamColors = [
    '#FB8500', // Orange Simba
    '#06D6A0', // Emerald Chui
    '#219EBC', // Cyan Ndovu
    '#E63946', // Maasai Red Kifaru
  ];

  static const String defaultLanguage = 'en';
  static const bool defaultFamilyFriendly = true;
  static const bool defaultDrinkingMode = false;
}
