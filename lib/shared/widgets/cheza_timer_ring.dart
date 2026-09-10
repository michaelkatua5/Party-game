import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class ChezaTimerRing extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final double size;

  const ChezaTimerRing({
    super.key,
    required this.remainingSeconds,
    this.totalSeconds = 60,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (totalSeconds > 0)
        ? (remainingSeconds / totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    final isUrgent = remainingSeconds <= 10;
    final timerColor = isUrgent
        ? AppColors.coralRed
        : (remainingSeconds <= 20 ? AppColors.savannaGold : AppColors.neonGreen);

    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF10141D),
        boxShadow: [
          if (isUrgent)
            BoxShadow(
              color: AppColors.coralRed.withOpacity(0.4),
              blurRadius: 16,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _TimerRingPainter(
              progress: progress,
              color: timerColor,
              backgroundColor: const Color(0xFF232B3E),
            ),
          ),
          Text(
            '$minutes:$seconds',
            style: AppTypography.buttonLarge.copyWith(
              fontSize: size * 0.22,
              fontWeight: FontWeight.w900,
              color: isUrgent ? AppColors.coralRed : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _TimerRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 5.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
