import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../domain/models/game_session.dart';
import '../../../shared/widgets/kenyan_button.dart';
import '../providers/game_controller.dart';

class RoundSummaryDialog extends ConsumerWidget {
  final GameSession session;

  const RoundSummaryDialog({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final winning = session.winningTeam;
    final maxScore = session.teams.fold<int>(
      1,
      (max, t) => t.score > max ? t.score : max,
    );

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text(
          'SCOREBOARD',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Round Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.neonGreen),
                ),
                child: Text(
                  'ROUND ${session.currentRound}',
                  style: const TextStyle(
                    color: AppColors.neonGreen,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Team Score Progress Bars matching Blueprint
              ...session.teams.map((team) {
                final isLeader = winning != null && team.id == winning.id;
                final progress = maxScore > 0 ? (team.score / maxScore).clamp(0.1, 1.0) : 0.1;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isLeader ? AppColors.neonGreen : AppColors.darkCardBorder,
                        width: isLeader ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              team.name.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${team.score}',
                              style: TextStyle(
                                color: isLeader ? AppColors.neonGreen : Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: AppColors.darkInput,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isLeader ? AppColors.neonGreen : AppColors.sunsetOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 14),

              // Leading Banner
              if (winning != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.savannaGold,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${winning.name.toUpperCase()} Leading! 🔥',
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

              const SizedBox(height: 28),

              // Badges Earned Shelf
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ROUND BADGES',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _RoundBadge(title: 'First Win', emoji: '🏆', color: AppColors.savannaGold),
                  _RoundBadge(title: '10 Correct', emoji: '🎯', color: AppColors.neonGreen),
                  _RoundBadge(title: 'Speed Demon', emoji: '⚡', color: AppColors.partyPurple),
                ],
              ),

              const Spacer(),

              // Next Round Action Button
              KenyanButton(
                text: 'START NEXT ROUND 🚀',
                gradient: AppColors.primaryGradient,
                height: 56,
                onPressed: () {
                  ref.read(gameControllerProvider.notifier).proceedToNextTurn();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundBadge extends StatelessWidget {
  final String title;
  final String emoji;
  final Color color;

  const _RoundBadge({required this.title, required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
