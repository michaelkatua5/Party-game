import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../domain/models/word.dart';
import 'cheza_badge.dart';

class ChezaGameCard extends StatelessWidget {
  final GameWord? word;
  final String categoryName;
  final Color categoryColor;
  final bool isPractice;

  const ChezaGameCard({
    super.key,
    required this.word,
    this.categoryName = 'KENYAN VIBES',
    this.categoryColor = AppColors.savannaGold,
    this.isPractice = false,
  });

  Color _getDifficultyColor(String diff) {
    switch (diff.toLowerCase()) {
      case 'easy':
        return AppColors.neonGreen;
      case 'hard':
        return AppColors.coralRed;
      case 'medium':
      default:
        return AppColors.savannaGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final wordText = word?.word.toUpperCase() ?? 'MUTURA';
    final difficulty = word?.difficulty.toUpperCase() ?? 'MEDIUM';
    final diffColor = _getDifficultyColor(difficulty);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            categoryColor.withOpacity(0.8),
            categoryColor.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: categoryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Top Badges Row: Category & Difficulty
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ChezaBadge(
                label: categoryName,
                color: Colors.white,
                icon: Icons.local_fire_department_rounded,
              ),
              ChezaBadge(
                label: difficulty,
                color: diffColor,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Central Word (The Visual Hero)
          Hero(
            tag: 'active_game_word_$wordText',
            child: Material(
              color: Colors.transparent,
              child: Text(
                wordText,
                textAlign: TextAlign.center,
                style: AppTypography.gameWordCard.copyWith(
                  fontSize: wordText.length > 12 ? 30 : (wordText.length > 8 ? 36 : 44),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Bottom Action Rule Hint
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white24),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🎭', style: TextStyle(fontSize: 14)),
                SizedBox(width: 8),
                Text(
                  'ACT IT OUT! NO TALKING!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
