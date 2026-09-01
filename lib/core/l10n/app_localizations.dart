import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'CHEZA!',
      'app_subtitle': 'Kenyan Charades & Party Game',
      'play_now': 'PLAY NOW',
      'quick_play': 'Quick Play',
      'custom_game': 'Custom Game',
      'categories': 'Categories',
      'leaderboard': 'Leaderboard',
      'how_to_play': 'How to Play',
      'settings': 'Settings',
      'practice': 'Practice Solo',
      'start_game': 'Start Game',
      'correct': 'CORRECT',
      'pass': 'PASS',
      'wrong': 'WRONG',
      'time_remaining': 'Time Left',
      'current_turn': 'Current Turn',
      'round': 'Round',
      'team': 'Team',
      'winner': 'WINNER!',
      'final_scores': 'Final Scores',
      'play_again': 'Play Again',
      'home': 'Home',
      'share_results': 'Share Results',
      'sound': 'Sound Effects',
      'haptics': 'Haptic Vibration',
      'language': 'Language',
      'family_friendly': 'Family Friendly Mode',
      'drinking_mode': 'Party / Drinking Mode',
      'drinking_warning': 'Please drink responsibly. Alcohol is not required to play.',
      'pause': 'Pause',
      'resume': 'Resume',
      'quit_game': 'Quit Game',
      'game_over': 'Game Finished!',
      'streak': 'Streak',
      'mvp': 'MVP Player',
    },
    'sw': {
      'app_title': 'CHEZA!',
      'app_subtitle': 'Mchezo wa Charades na Sherehe Kenya',
      'play_now': 'CHEZA SASA',
      'quick_play': 'Mchezo wa Haraka',
      'custom_game': 'Mchezo wa Kupanga',
      'categories': 'Vitengo',
      'leaderboard': 'Mabingwa',
      'how_to_play': 'Jinsi ya Kucheza',
      'settings': 'Mipangilio',
      'practice': 'Jifunze Peke Yako',
      'start_game': 'Anza Mchezo',
      'correct': 'SAHIHI',
      'pass': 'PITA',
      'wrong': 'KOSA',
      'time_remaining': 'Muda Uliobaki',
      'current_turn': 'Zamu ya Sasa',
      'round': 'Awamu',
      'team': 'Timu',
      'winner': 'MSHINDI!',
      'final_scores': 'Matokeo Kamili',
      'play_again': 'Cheza Tena',
      'home': 'Nyumbani',
      'share_results': 'Tuma Matokeo',
      'sound': 'Sauti za Mchezo',
      'haptics': 'Mtetemo',
      'language': 'Lugha',
      'family_friendly': 'Hali ya Familia',
      'drinking_mode': 'Hali ya Sherehe / Vinywaji',
      'drinking_warning': 'Kunywa kwa uangalifu. Pombe si lazima ili kucheza.',
      'pause': 'Simamisha',
      'resume': 'Endelea',
      'quit_game': 'Toka Mchezoni',
      'game_over': 'Mchezo Umekamilika!',
      'streak': 'Mfululizo',
      'mvp': 'Mchezaji Bora',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'sw'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
