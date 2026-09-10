import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/cheza_button.dart';
import '../../../shared/widgets/cheza_card.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          'HOW TO PLAY',
          style: AppTypography.h2.copyWith(letterSpacing: 1.2),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Rule 1: Forehead Position
              _buildRuleCard(
                step: '1',
                title: 'PLACE PHONE ON FOREHEAD',
                description: 'Hold the phone against your forehead facing your friends. You must not look at the screen!',
                icon: Icons.phone_android_rounded,
                accentColor: AppColors.savannaGold,
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 14),

              // Rule 2: Act & Guess
              _buildRuleCard(
                step: '2',
                title: 'FRIENDS ACT IT OUT',
                description: 'Your team acts out the Kenyan slang, food, celebrity or trend. NO speaking the word, humming, or rhyming!',
                icon: Icons.theater_comedy_rounded,
                accentColor: AppColors.neonGreen,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 14),

              // Rule 3: Tilt Up for Correct
              _buildRuleCard(
                step: '3',
                title: 'TILT UP = GOT IT (+1 PT)',
                description: 'When you guess correctly, tilt your forehead upward to score 1 point and load the next card.',
                icon: Icons.arrow_upward_rounded,
                accentColor: AppColors.forestEmerald,
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 14),

              // Rule 4: Tilt Down to Pass
              _buildRuleCard(
                step: '4',
                title: 'TILT DOWN = PASS (SKIP)',
                description: 'Stuck? Tilt your head downward to skip the card. Try to score as many points before the 60s timer expires!',
                icon: Icons.arrow_downward_rounded,
                accentColor: AppColors.coralRed,
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 14),

              // Rule 5: Kings Cup Rules
              _buildRuleCard(
                step: '5',
                title: 'KINGS CUP PARTY RULES',
                description: 'Draw cards from the 52-card party deck. Follow interactive forfeits, assign mates, and avoid the 4th King!',
                icon: Icons.workspace_premium_rounded,
                accentColor: AppColors.cyberPink,
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 24),

              ChezaButton(
                text: 'LET\'S PLAY! 🎭',
                variant: ChezaButtonVariant.primary,
                onPressed: () => context.push('/game-modes'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleCard({
    required String step,
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
  }) {
    return ChezaCard(
      padding: const EdgeInsets.all(18),
      borderColor: accentColor.withOpacity(0.35),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.18),
              shape: BoxShape.circle,
              border: Border.all(color: accentColor.withOpacity(0.4), width: 1.5),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'STEP $step',
                        style: TextStyle(color: accentColor, fontSize: 9, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.h3.copyWith(fontSize: 14, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
