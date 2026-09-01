import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/share_util.dart';
import '../../../shared/widgets/confetti_overlay.dart';
import '../../../shared/widgets/friends_illustration.dart';
import '../../../shared/widgets/kenyan_button.dart';
import '../../game/providers/game_controller.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(gameControllerProvider);

    if (session == null) {
      return Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Back to Home'),
          ),
        ),
      );
    }

    final winningTeam = session.winningTeam ?? session.teams.first;
    final otherTeams = session.teams.where((t) => t.id != winningTeam.id).toList();
    final runnerUp = otherTeams.isNotEmpty ? otherTeams.first : null;

    return ConfettiOverlay(
      isPlaying: true,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header: Winner Banner
                Center(
                  child: Column(
                    children: [
                      Text(
                        '🏆 ${winningTeam.name.toUpperCase()} WINS!',
                        textAlign: TextAlign.center,
                        style: AppTypography.displayLarge.copyWith(
                          color: AppColors.savannaGold,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${winningTeam.score} - ${runnerUp?.score ?? 0}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Friends Celebrating Illustration
                const FriendsIllustration(height: 120),

                const SizedBox(height: 18),

                // Match MVP & Highlights Badges matching Blueprint
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.darkCardBorder),
                  ),
                  child: Column(
                    children: [
                      _buildHighlightRow('⭐ MVP', 'Michael (9 pts)', AppColors.savannaGold),
                      const Divider(color: AppColors.darkCardBorder, height: 16),
                      _buildHighlightRow('⚡ Fastest Guess', 'Ivy (3.2s)', AppColors.neonGreen),
                      const Divider(color: AppColors.darkCardBorder, height: 16),
                      _buildHighlightRow('🔄 Most Passes', 'Kevin (3)', AppColors.coralRed),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Shareable Match Card matching Blueprint
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'WE JUST PLAYED CHEZA!',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '🏆 ${winningTeam.name.toUpperCase()} 🏆\n${winningTeam.score} - ${runnerUp?.score ?? 0} WINNERS',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF990000), // Kenyan Red
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircleAvatar(radius: 14, backgroundColor: Color(0xFFFFB703), child: Text('🙋🏾‍♂️', style: TextStyle(fontSize: 12))),
                          SizedBox(width: 6),
                          CircleAvatar(radius: 14, backgroundColor: Color(0xFFFF006E), child: Text('🙆🏾‍♀️', style: TextStyle(fontSize: 12))),
                          SizedBox(width: 6),
                          CircleAvatar(radius: 14, backgroundColor: Color(0xFF06D6A0), child: Text('🧑🏾', style: TextStyle(fontSize: 12))),
                          SizedBox(width: 6),
                          CircleAvatar(radius: 14, backgroundColor: Color(0xFF219EBC), child: Text('💁🏾‍♀️', style: TextStyle(fontSize: 12))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '#Cheza #KenyanCharades #NaiParty',
                        style: TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Share Button
                KenyanButton(
                  text: '📤 SHARE MATCH CARD',
                  backgroundColor: AppColors.partyPurple,
                  height: 52,
                  onPressed: () {
                    ShareUtil.shareGameResult(
                      winningTeam: winningTeam.name,
                      winningScore: winningTeam.score,
                      runnerUpTeam: runnerUp?.name ?? 'Squad',
                      runnerUpScore: runnerUp?.score ?? 0,
                      mvpPlayer: 'Michael',
                    );
                  },
                ),

                const SizedBox(height: 10),

                // Play Again
                KenyanButton(
                  text: '🔄 PLAY AGAIN',
                  gradient: AppColors.primaryGradient,
                  height: 52,
                  onPressed: () {
                    ref.read(gameControllerProvider.notifier).restartGame();
                    context.go('/game');
                  },
                ),

                const SizedBox(height: 10),

                // Home
                KenyanButton(
                  text: '🏠 HOME',
                  isSecondary: true,
                  height: 52,
                  onPressed: () {
                    ref.read(gameControllerProvider.notifier).resetGame();
                    context.go('/home');
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
