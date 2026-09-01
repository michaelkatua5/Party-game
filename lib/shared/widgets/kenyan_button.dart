import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

class KenyanButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color textColor;
  final double height;
  final bool isSecondary;
  final bool isDestructive;

  const KenyanButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.gradient,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.height = AppDimensions.buttonHeight,
    this.isSecondary = false,
    this.isDestructive = false,
  });

  @override
  State<KenyanButton> createState() => _KenyanButtonState();
}

class _KenyanButtonState extends State<KenyanButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = widget.gradient ??
        (widget.isDestructive
            ? AppColors.maasaiGradient
            : (widget.isSecondary ? null : AppColors.primaryGradient));

    final effectiveBg = widget.backgroundColor ??
        (widget.isSecondary ? AppColors.darkCard : null);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (widget.onPressed != null) {
          HapticFeedback.lightImpact();
          widget.onPressed!();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: widget.height,
        transform: Matrix4.translationValues(0, _isPressed ? 3 : 0, 0),
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          color: effectiveBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: widget.isSecondary
              ? Border.all(color: AppColors.darkCardBorder, width: 1.5)
              : null,
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: (widget.isDestructive
                            ? AppColors.maasaiRed
                            : (widget.isSecondary
                                ? Colors.black26
                                : AppColors.sunsetOrange))
                        .withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: widget.textColor, size: 22),
              const SizedBox(width: 8),
            ],
            Text(
              widget.text,
              style: TextStyle(
                color: widget.textColor,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
