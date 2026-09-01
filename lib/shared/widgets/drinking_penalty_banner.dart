import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

class DrinkingPenaltyBanner extends StatelessWidget {
  final String penaltyText;
  final VoidCallback? onDismiss;

  const DrinkingPenaltyBanner({
    super.key,
    required this.penaltyText,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.purpleSherehe.withOpacity(0.25),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.hotPink, width: 1.5),
      ),
      child: Row(
        children: [
          const Text('🍻', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PARTY PENALTY',
                  style: TextStyle(
                    color: AppColors.hotPink,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  penaltyText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70, size: 18),
              onPressed: onDismiss,
            ),
        ],
      ),
    );
  }
}
