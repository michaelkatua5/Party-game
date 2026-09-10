import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/haptic_service.dart';
import '../../../domain/models/game_session.dart';
import '../../../shared/widgets/cheza_button.dart';

class RoundSummaryDialog extends ConsumerWidget {
  final GameSession session;

  const RoundSummaryDialog({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teams = session.teams;
    final currentTeam = session.currentTeam;
    final isGameOver = session.status == GameStatus.completed;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Time's Up Header
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.savannaGold.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.savannaGold.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⏰ ', style: TextStyle(fontSize: 18)),
                      Text(
                        'TIME\'S UP! • ROUND ${session.currentRound}',
                        style: AppTypography.badge.copyWith(color: AppColors.savannaGold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn().scale(duration: 300.ms),

              const SizedBox(height: 18),

              Text(
                'ROUND SUMMARY',
                textAlign: TextAlign.center,
                style: AppTypography.displayMedium.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              // 2. Turn Recap Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.darkCardBorder),
                ),
                child: Column(
                  children: [
                    Text(
                      currentTeam.name.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.savannaGold,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '+${currentTeam.correctCount} CORRECT',
                      style: const TextStyle(
                        color: AppColors.neonGreen,
                        fontWeight: FontWeight.w900,
                        fontSize: 32,
                      ),
                    ),
                    Text(
                      '${currentTeam.passCount} passed',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 18),

              // 3. Teams Total Scores Overview
              ...teams.map((t) {
                final isCurrent = t.id == currentTeam.id;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: isCurrent ? const Color(0xFF1E2638) : AppColors.darkCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCurrent ? AppColors.savannaGold.withOpacity(0.5) : AppColors.darkCardBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(isCurrent ? '👉 ' : '🦁 '),
                          Text(
                            t.name,
                            style: TextStyle(
                              color: isCurrent ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${t.score} PTS',
                        style: TextStyle(
                          color: isCurrent ? AppColors.savannaGold : Colors.white60,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              // 4. Primary CTA: Route directly to next team's category selection OR results
              if (isGameOver)
                ChezaButton(
                  text: 'SEE FINAL RESULTS 🏆',
                  variant: ChezaButtonVariant.primary,
                  onPressed: () {
                    ref.read(hapticServiceProvider).trigger(HapticType.success);
                    context.go('/results');
                  },
                )
              else
                ChezaButton(
                  text: 'NEXT: ${session.nextTeam.name.toUpperCase()} → PICK VIBE',
                  variant: ChezaButtonVariant.primary,
                  onPressed: () {
                    ref.read(hapticServiceProvider).trigger(HapticType.medium);
                    // Route directly to Category Selection for next team!
                    context.go('/category-select');
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
