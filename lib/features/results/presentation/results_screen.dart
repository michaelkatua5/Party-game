import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/share_util.dart';
import '../../../shared/widgets/cheza_button.dart';
import '../../../shared/widgets/confetti_overlay.dart';
import '../../game/providers/game_controller.dart';
import '../../settings/providers/settings_provider.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(gameControllerProvider);
    final settings = ref.watch(settingsNotifierProvider);
    final isDark = settings.isDarkMode;

    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final textMain = isDark ? Colors.white : AppColors.textDark;
    final textSub = isDark ? AppColors.textMuted : const Color(0xFF64748B);
    final borderColor = isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0);

    if (session == null) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(
          child: ChezaButton(
            text: 'Return to Home',
            isFullWidth: false,
            onPressed: () => context.go('/home'),
          ),
        ),
      );
    }

    final winningTeam = session.winningTeam;
    final totalCorrect = session.teams.fold<int>(0, (sum, t) => sum + t.score);

    return ConfettiOverlay(
      isPlaying: true,
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingL,
              vertical: AppDimensions.paddingM,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),

                // Top Celebration Tag
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.savannaGold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '🏆 MATCH COMPLETE',
                      style: TextStyle(
                        color: AppColors.savannaGold,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ).animate().fadeIn().scale(duration: 300.ms),

                const SizedBox(height: 16),

                // Champion Announcement
                Text(
                  '${winningTeam?.name.toUpperCase() ?? 'CHAMPION'} WINS!',
                  textAlign: TextAlign.center,
                  style: AppTypography.displayLarge.copyWith(
                    color: textMain,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ).animate().fadeIn(delay: 150.ms).scale(duration: 350.ms, curve: Curves.easeOutBack),

                Text(
                  'What an insane round! 🇰🇪🔥',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textSub, fontSize: 14),
                ),

                const SizedBox(height: 24),

                // Final Scoreboard Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      ...session.teams.map((t) {
                        final isWinner = t.id == winningTeam?.id;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isWinner
                                ? AppColors.savannaGold.withOpacity(0.12)
                                : (isDark ? const Color(0xFF141926) : const Color(0xFFF8FAFC)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isWinner ? AppColors.savannaGold : borderColor,
                              width: isWinner ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(isWinner ? '👑 ' : '🥈 ', style: const TextStyle(fontSize: 18)),
                                  Text(
                                    t.name,
                                    style: TextStyle(
                                      color: textMain,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${t.score} PTS',
                                style: TextStyle(
                                  color: isWinner ? AppColors.savannaGold : textMain,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMatchStat('Total Correct', '$totalCorrect', textMain, textSub),
                          _buildMatchStat('Rounds Played', '${session.currentRound - 1}', textMain, textSub),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 24),

                // Share Result Button
                ChezaButton(
                  text: 'SHARE RESULT 📱',
                  variant: ChezaButtonVariant.secondary,
                  icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                  onPressed: () {
                    final text = '🔥 We just played CHEZA! ${winningTeam?.name} won with ${winningTeam?.score} points! #Cheza #KenyanCharades';
                    ShareUtil.shareMatchResult(text);
                  },
                ),

                const SizedBox(height: 12),

                // Play Again Button
                ChezaButton(
                  text: 'PLAY AGAIN 🔁',
                  variant: ChezaButtonVariant.primary,
                  onPressed: () {
                    ref.read(gameControllerProvider.notifier).restartGame();
                    context.go('/category-select');
                  },
                ),

                const SizedBox(height: 8),

                // New Game / Return to Menu
                TextButton(
                  onPressed: () {
                    ref.read(gameControllerProvider.notifier).resetGame();
                    context.go('/home');
                  },
                  child: Text(
                    'Return to Game Selection',
                    style: TextStyle(color: textSub, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchStat(String label, String value, Color textMain, Color textSub) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.h2.copyWith(fontSize: 20, color: textMain),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.micro.copyWith(fontSize: 11, color: textSub),
        ),
      ],
    );
  }
}
