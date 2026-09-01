import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PlayerAvatarChip extends StatelessWidget {
  final String name;
  final String emoji;
  final Color borderColor;
  final VoidCallback? onRemove;
  final double radius;

  const PlayerAvatarChip({
    super.key,
    required this.name,
    this.emoji = '🧑🏾',
    this.borderColor = AppColors.savannaGold,
    this.onRemove,
    this.radius = 36.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: borderColor.withOpacity(0.2),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: borderColor.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                emoji,
                style: TextStyle(fontSize: radius * 1.05),
              ),
            ),
            if (onRemove != null)
              Positioned(
                top: -2,
                right: -2,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.coralRed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 12),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
