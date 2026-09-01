import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

class GradientCard extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Border? border;

  const GradientCard({
    super.key,
    required this.child,
    this.gradient,
    this.backgroundColor,
    this.onTap,
    this.padding = const EdgeInsets.all(AppDimensions.paddingM),
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.darkCard,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: border ?? Border.all(color: AppColors.darkCardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}
