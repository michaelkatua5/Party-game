import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/cheza_card.dart';
import '../../../shared/widgets/cheza_section_header.dart';
import '../../game/providers/game_controller.dart';
import '../../kings_cup/providers/kings_cup_controller.dart';

class GameModeSelectionScreen extends ConsumerWidget {
  const GameModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'SELECT GAME MODE',
          style: AppTypography.h2.copyWith(letterSpacing: 1.2),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Guided Flow Step Indicator (Step 1 of 4)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.darkCardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStepIndicator('1. Mode', isActive: true),
                    const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
                    _buildStepIndicator('2. Players', isActive: false),
                    const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
                    _buildStepIndicator('3. Packs', isActive: false),
                    const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
                    _buildStepIndicator('4. Play', isActive: false),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const ChezaSectionHeader(
                title: 'HOW ARE WE PLAYING TONIGHT?',
                subtitle: 'Pick the game style that matches your group energy',
              ),

              const SizedBox(height: 12),

              // 1. TEAMS BATTLE (Charades)
              _buildModeOption(
                title: 'TEAMS BATTLE',
                subtitle: 'Split into 2 or 3 squads and battle for supremacy.',
                badge: 'RECOMMENDED',
                badgeColor: AppColors.savannaGold,
                icon: Icons.groups_rounded,
                accentColor: AppColors.savannaGold,
                onTap: () => context.push('/player-setup'),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.08, end: 0),

              const SizedBox(height: 14),

              // 2. QUICK PLAY (Instant Start)
              _buildModeOption(
                title: 'QUICK PLAY',
                subtitle: 'Jump straight into 60s rounds with curated top packs.',
                badge: 'FAST START',
                badgeColor: AppColors.neonGreen,
                icon: Icons.flash_on_rounded,
                accentColor: AppColors.neonGreen,
                onTap: () async {
                  await ref.read(gameControllerProvider.notifier).startQuickPlay();
                  if (context.mounted) context.push('/charades-calibration');
                },
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.08, end: 0),

              const SizedBox(height: 14),

              // 3. KINGS CUP (Cards & Dares)
              _buildModeOption(
                title: 'KINGS CUP 👑',
                subtitle: '52-card digital party board with Kenyan forfeits & mates.',
                badge: 'PARTY FAVORITE',
                badgeColor: AppColors.cyberPink,
                icon: Icons.workspace_premium_rounded,
                accentColor: AppColors.cyberPink,
                onTap: () {
                  ref.read(kingsCupControllerProvider.notifier).startNewGame();
                  context.push('/kings-cup');
                },
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.08, end: 0),

              const SizedBox(height: 14),

              // 4. CUSTOM GAME (Full Control)
              _buildModeOption(
                title: 'CUSTOM RULES',
                subtitle: 'Customize timer duration, difficulty, and pass penalties.',
                badge: 'ADVANCED',
                badgeColor: AppColors.electricCyan,
                icon: Icons.tune_rounded,
                accentColor: AppColors.electricCyan,
                onTap: () => context.push('/custom-game'),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.08, end: 0),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(String text, {required bool isActive}) {
    return Text(
      text,
      style: TextStyle(
        color: isActive ? AppColors.savannaGold : Colors.white38,
        fontSize: 12,
        fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
      ),
    );
  }

  Widget _buildModeOption({
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return ChezaCard(
      padding: const EdgeInsets.all(18),
      borderColor: accentColor.withOpacity(0.35),
      hasGlow: true,
      glowColor: accentColor,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: accentColor.withOpacity(0.4), width: 1.5),
            ),
            child: Icon(icon, color: accentColor, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTypography.h3.copyWith(fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(color: badgeColor, fontSize: 8, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(fontSize: 12, height: 1.25),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 16),
        ],
      ),
    );
  }
}
