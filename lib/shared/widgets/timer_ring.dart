import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class TimerRing extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final double size;

  const TimerRing({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    this.size = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0 ? (remainingSeconds / totalSeconds).clamp(0.0, 1.0) : 0.0;

    Color ringColor;
    if (remainingSeconds <= 10) {
      ringColor = AppColors.maasaiRed;
    } else if (remainingSeconds <= 20) {
      ringColor = AppColors.savannaGold;
    } else {
      ringColor = AppColors.forestEmerald;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress,
              color: ringColor,
              backgroundColor: AppColors.darkCardBorder,
              strokeWidth: 7.0,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$remainingSeconds',
                style: TextStyle(
                  color: ringColor,
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'SEC',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: size * 0.12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
