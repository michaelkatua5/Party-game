import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

class ChezaCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final Gradient? gradient;
  final double borderRadius;
  final bool hasGlow;
  final Color? glowColor;

  const ChezaCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.borderColor,
    this.gradient,
    this.borderRadius = 20,
    this.hasGlow = false,
    this.glowColor,
  });

  @override
  State<ChezaCard> createState() => _ChezaCardState();
}

class _ChezaCardState extends State<ChezaCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = widget.borderColor ?? AppColors.darkCardBorder;
    final effectiveBg = widget.backgroundColor ?? AppColors.darkCard;

    final Widget cardContent = Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.gradient == null ? effectiveBg : null,
        gradient: widget.gradient,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: effectiveBorderColor, width: 1.5),
        boxShadow: [
          if (widget.hasGlow && widget.glowColor != null)
            BoxShadow(
              color: widget.glowColor!.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: widget.child,
    );

    if (widget.onTap == null) {
      return cardContent;
    }

    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          HapticFeedback.lightImpact();
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: cardContent,
      ),
    );
  }
}
