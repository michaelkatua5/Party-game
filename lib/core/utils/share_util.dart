import 'package:share_plus/share_plus.dart';

class ShareUtil {
  static Future<void> shareGameResult({
    required String winningTeam,
    required int winningScore,
    required String runnerUpTeam,
    required int runnerUpScore,
    required String mvpPlayer,
  }) async {
    final message = '''
🔥 CHEZA! KENYAN CHARADES SHOWDOWN 🔥

🏆 Champion: $winningTeam ($winningScore pts)
🥈 Runner-up: $runnerUpTeam ($runnerUpScore pts)
⭐ MVP: $mvpPlayer

Tunacheza CHEZA! - The Ultimate Kenyan Party Game 🇰🇪🎉
Download now & challenge your squad!
''';

    try {
      await Share.share(message, subject: 'CHEZA! Game Results');
    } catch (_) {
      // Fallback
    }
  }
}
