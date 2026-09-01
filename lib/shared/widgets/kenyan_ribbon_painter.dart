import 'package:flutter/material.dart';

enum RibbonPosition { topLeft, bottomRight }

class KenyanRibbon extends StatelessWidget {
  final RibbonPosition position;
  final double size;

  const KenyanRibbon({
    super.key,
    required this.position,
    this.size = 140.0,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RibbonPainter(position: position),
        ),
      ),
    );
  }
}

class _RibbonPainter extends CustomPainter {
  final RibbonPosition position;

  _RibbonPainter({required this.position});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Colors of Kenyan flag ribbons
    final colors = [
      const Color(0xFF006600), // Kenyan Green
      Colors.white,
      const Color(0xFF990000), // Kenyan Red
      Colors.white,
      const Color(0xFF006600), // Kenyan Green
    ];

    final strokeWidth = size.width * 0.05;

    for (int i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final path = Path();
      final offset = i * (strokeWidth * 0.9);

      if (position == RibbonPosition.topLeft) {
        path.moveTo(0, h * 0.7 - offset);
        path.quadraticBezierTo(w * 0.4, h * 0.4 - offset, w * 0.8 - offset, 0);
      } else {
        path.moveTo(w, h * 0.3 + offset);
        path.quadraticBezierTo(w * 0.6, h * 0.6 + offset, w * 0.2 + offset, h);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
