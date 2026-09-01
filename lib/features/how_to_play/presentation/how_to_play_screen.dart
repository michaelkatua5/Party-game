import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../shared/widgets/friends_illustration.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'HOW TO PLAY',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL, vertical: 12),
        children: [
          // Step 1: PASS THE PHONE
          _buildStepCard(
            stepNumber: '1',
            title: 'PASS THE PHONE',
            description: 'Hand the phone to the designated actor on your team.',
            iconEmoji: '📱',
            accentColor: AppColors.electricCyan,
          ),

          const SizedBox(height: 12),

          // Step 2: ACT OUT THE WORD
          _buildStepCard(
            stepNumber: '2',
            title: 'ACT OUT THE WORD',
            description: 'Actor acts out the Kenyan slang, food, or place without speaking, mouthing, or spelling.',
            iconEmoji: '🎭',
            accentColor: AppColors.savannaGold,
          ),

          const SizedBox(height: 12),

          // Step 3: FRIENDS GUESS
          _buildStepCard(
            stepNumber: '3',
            title: 'FRIENDS GUESS',
            description: 'Teammates shout out guesses before the round countdown timer runs out.',
            iconEmoji: '🗣️',
            accentColor: AppColors.sunsetOrange,
          ),

          const SizedBox(height: 12),

          // Step 4: GET POINTS
          _buildStepCard(
            stepNumber: '4',
            title: 'GET POINTS',
            description: 'Tap "✓ GOT IT" for +1 point, or "↻ PASS" if too difficult.',
            iconEmoji: '💯',
            accentColor: AppColors.neonGreen,
          ),

          const SizedBox(height: 12),

          // Step 5: WIN!
          _buildStepCard(
            stepNumber: '5',
            title: 'WIN!',
            description: 'Highest scoring team after all rounds is crowned the champion!',
            iconEmoji: '👑',
            accentColor: AppColors.partyPurple,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required String description,
    required String iconEmoji,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: accentColor,
            child: Text(
              stepNumber,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(iconEmoji, style: const TextStyle(fontSize: 28)),
        ],
      ),
    );
  }
}
