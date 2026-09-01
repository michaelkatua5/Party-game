import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool isPlaying;

  const ConfettiOverlay({
    super.key,
    required this.child,
    this.isPlaying = true,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final Random _rnd = Random();

  final List<Color> _colors = [
    AppColors.savannaGold,
    AppColors.sunsetOrange,
    AppColors.maasaiRed,
    AppColors.forestEmerald,
    AppColors.riftCyan,
    AppColors.purpleSherehe,
    AppColors.hotPink,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() => setState(() {}));

    if (widget.isPlaying) {
      _initParticles();
      _controller.repeat();
    }
  }

  void _initParticles() {
    _particles.clear();
    for (int i = 0; i < 60; i++) {
      _particles.add(
        _ConfettiParticle(
          x: _rnd.nextDouble(),
          y: _rnd.nextDouble() * -0.5,
          speed: 0.2 + _rnd.nextDouble() * 0.5,
          size: 6 + _rnd.nextDouble() * 8,
          rotation: _rnd.nextDouble() * 2 * pi,
          rotationSpeed: (_rnd.nextDouble() - 0.5) * 4,
          color: _colors[_rnd.nextInt(_colors.length)],
        ),
      );
    }
  }

  @override
  void didUpdateWidget(covariant ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _initParticles();
      _controller.repeat();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (widget.isPlaying)
          IgnorePointer(
            child: CustomPaint(
              painter: _ConfettiPainter(
                particles: _particles,
                progress: _controller.value,
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  double speed;
  double size;
  double rotation;
  double rotationSpeed;
  Color color;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final currentY = (p.y + progress * p.speed * 2) % 1.2;
      final posX = p.x * size.width;
      final posY = (currentY - 0.1) * size.height;

      final paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(posX, posY);
      canvas.rotate(p.rotation + progress * p.rotationSpeed * 5);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
