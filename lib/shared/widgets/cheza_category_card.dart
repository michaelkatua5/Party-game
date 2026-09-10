import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../domain/models/category.dart';

class ChezaCategoryCard extends StatefulWidget {
  final GameCategory category;
  final bool isSelected;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;
  final int cardCount;

  const ChezaCategoryCard({
    super.key,
    required this.category,
    required this.isSelected,
    this.onToggle,
    this.onTap,
    this.cardCount = 30,
  });

  @override
  State<ChezaCategoryCard> createState() => _ChezaCategoryCardState();
}

class _ChezaCategoryCardState extends State<ChezaCategoryCard> {
  bool _isPressed = false;

  Color _parseColor(String? hexString) {
    if (hexString == null) return AppColors.savannaGold;
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppColors.savannaGold;
    }
  }

  IconData _getCategoryIcon(String iconKey) {
    switch (iconKey.toLowerCase()) {
      case 'chatbubble_ellipses':
      case 'sheng':
        return Icons.forum_rounded;
      case 'restaurant':
      case 'food':
        return Icons.restaurant_rounded;
      case 'location':
      case 'places':
        return Icons.location_on_rounded;
      case 'people':
      case 'culture':
        return Icons.diversity_3_rounded;
      case 'school':
      case 'campus':
        return Icons.school_rounded;
      case 'football':
      case 'sports':
        return Icons.sports_soccer_rounded;
      case 'musical_notes':
      case 'music':
        return Icons.headphones_rounded;
      case 'heart':
      case 'dating':
        return Icons.favorite_rounded;
      case 'beer':
      case 'party':
        return Icons.celebration_rounded;
      case 'happy':
      case 'memes':
        return Icons.sentiment_very_satisfied_rounded;
      case 'directions_bus':
      case 'matatu':
        return Icons.directions_bus_filled_rounded;
      case 'star':
      case 'celebrities':
        return Icons.stars_rounded;
      case 'movie':
      case 'tv':
        return Icons.movie_filter_rounded;
      case 'how_to_reg':
      case 'politics':
        return Icons.account_balance_rounded;
      case 'work':
      case 'hustles':
        return Icons.work_rounded;
      case 'smartphone':
      case 'internet':
        return Icons.tag_rounded;
      case 'child_care':
      case 'childhood':
        return Icons.sports_esports_rounded;
      case 'store':
      case 'brands':
        return Icons.storefront_rounded;
      default:
        return Icons.local_fire_department_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _parseColor(widget.category.color);
    final isSelected = widget.isSelected;

    return AnimatedScale(
      scale: _isPressed ? 0.96 : (isSelected ? 1.02 : 1.0),
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          HapticFeedback.selectionClick();
          widget.onTap?.call();
          widget.onToggle?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? themeColor.withOpacity(0.16) : AppColors.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? themeColor : AppColors.darkCardBorder,
              width: isSelected ? 2.2 : 1.2,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: themeColor.withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Icon & Checkmark row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? themeColor.withOpacity(0.25) : themeColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: themeColor.withOpacity(0.4), width: 1.2),
                    ),
                    child: Icon(
                      _getCategoryIcon(widget.category.icon),
                      color: themeColor,
                      size: 22,
                    ),
                  ),

                  // Selection Checkmark Pill
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isSelected ? themeColor : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? themeColor : Colors.white24,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: AppColors.textDark, size: 16)
                        : null,
                  ),
                ],
              ),

              const Spacer(),

              // Category Name
              Text(
                widget.category.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.h3.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 4),

              // Short Description
              Text(
                widget.category.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 11,
                  color: Colors.white60,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 10),

              // Card Count & Party Pill Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10141D),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Text(
                      '${widget.cardCount} cards',
                      style: AppTypography.micro.copyWith(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  if (widget.category.isParty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.cyberPink.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.cyberPink.withOpacity(0.4)),
                      ),
                      child: const Text(
                        '18+ 🍻',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.cyberPink),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
