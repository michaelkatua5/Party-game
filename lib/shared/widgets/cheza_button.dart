import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

enum ChezaButtonVariant { primary, secondary, danger, success, ghost, outline }

class ChezaButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ChezaButtonVariant variant;
  final Widget? icon;
  final bool isFullWidth;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final Gradient? gradient;

  const ChezaButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ChezaButtonVariant.primary,
    this.icon,
    this.isFullWidth = true,
    this.height = 54,
    this.borderRadius = 16,
    this.isLoading = false,
    this.gradient,
  });

  @override
  State<ChezaButton> createState() => _ChezaButtonState();
}

class _ChezaButtonState extends State<ChezaButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    Color bg;
    Color fg;
    Border? border;
    Gradient? grad = widget.gradient;

    switch (widget.variant) {
      case ChezaButtonVariant.primary:
        bg = AppColors.savannaGold;
        fg = AppColors.textDark;
        grad ??= AppColors.primaryGradient;
        break;
      case ChezaButtonVariant.success:
        bg = AppColors.neonGreen;
        fg = AppColors.textDark;
        grad ??= AppColors.gotItGradient;
        break;
      case ChezaButtonVariant.danger:
        bg = AppColors.coralRed;
        fg = Colors.white;
        grad ??= AppColors.passGradient;
        break;
      case ChezaButtonVariant.secondary:
        bg = const Color(0xFF1E2433);
        fg = Colors.white;
        border = Border.all(color: AppColors.darkCardBorder, width: 1.5);
        break;
      case ChezaButtonVariant.outline:
        bg = Colors.transparent;
        fg = Colors.white;
        border = Border.all(color: AppColors.darkCardBorder, width: 1.5);
        break;
      case ChezaButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.textMuted;
        break;
    }

    final Widget content = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        else ...[
          if (widget.icon != null) ...[
            widget.icon!,
            const SizedBox(width: 8),
          ],
          Text(
            widget.text,
            style: AppTypography.buttonLarge.copyWith(color: fg),
          ),
        ],
      ],
    );

    return AnimatedScale(
      scale: _isPressed && isEnabled ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled
            ? (_) {
                setState(() => _isPressed = false);
                HapticFeedback.lightImpact();
                widget.onPressed?.call();
              }
            : null,
        onTapCancel: () => setState(() => _isPressed = false),
        child: Container(
          height: widget.height,
          width: widget.isFullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: widget.isFullWidth ? 16 : 24),
          decoration: BoxDecoration(
            color: grad == null ? bg : null,
            gradient: grad,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: border,
            boxShadow: isEnabled && widget.variant != ChezaButtonVariant.ghost
                ? [
                    BoxShadow(
                      color: (grad != null ? bg : bg).withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );
  }
}
