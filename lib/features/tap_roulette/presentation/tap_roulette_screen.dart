import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/haptic_service.dart';
import '../data/tap_roulette_prompts.dart';

enum GameState { waiting, holding, spinning, finished }

class FingerPoint {
  final int id;
  Offset position;
  final Color color;
  final int playerNumber;

  FingerPoint({
    required this.id,
    required this.position,
    required this.color,
    required this.playerNumber,
  });
}

class TapRouletteScreen extends ConsumerStatefulWidget {
  const TapRouletteScreen({super.key});

  @override
  ConsumerState<TapRouletteScreen> createState() => _TapRouletteScreenState();
}

class _TapRouletteScreenState extends ConsumerState<TapRouletteScreen>
    with TickerProviderStateMixin {
  GameState _state = GameState.waiting;
  final Map<int, FingerPoint> _activeFingers = {};
  
  late final AnimationController _pulseController;
  late final AnimationController _holdController;

  int? _selectedPointerId;
  int? _currentlyHighlightedId;
  String _currentDare = "";
  
  // Debounce timer to prevent micro-touch jitter from resetting hold
  Timer? _liftGraceTimer;
  int _lastHapticStage = 0;

  // Ultra-saturated 100% luminous neon palette
  static const List<Color> _neonPalette = [
    Color(0xFF00FFFF), // Blinding Electric Cyan
    Color(0xFFFF0055), // Laser Neon Pink
    Color(0xFF00FF44), // Toxic Neon Green
    Color(0xFFFFEE00), // Laser Neon Yellow
    Color(0xFFFF5500), // Ultra Neon Orange
    Color(0xFFCC00FF), // Hyper Neon Violet
    Color(0xFFFF0033), // Pure Laser Red
    Color(0xFF00E5FF), // Radiant Sky Aqua
    Color(0xFF39FF14), // Radioactive Lime
    Color(0xFFFF00AA), // Hot Neon Magenta
  ];

  @override
  void initState() {
    super.initState();
    _generateDare();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _holdController.addListener(() {
      if (_state == GameState.holding) {
        setState(() {}); // Repaint charging arc
        
        final progress = _holdController.value;
        final currentStage = (progress * 4).floor();
        if (currentStage > _lastHapticStage) {
          _lastHapticStage = currentStage;
          ref.read(hapticServiceProvider).trigger(HapticType.selection);
          ref.read(audioServiceProvider).play(GameSound.countdownTick);
        }
      }
    });

    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _state == GameState.holding) {
        _startSpinning();
      }
    });
  }

  @override
  void dispose() {
    _liftGraceTimer?.cancel();
    _pulseController.dispose();
    _holdController.dispose();
    super.dispose();
  }

  void _generateDare() {
    final random = Random();
    _currentDare = tapRoulettePrompts[random.nextInt(tapRoulettePrompts.length)];
  }

  void _resetGame() {
    final haptic = ref.read(hapticServiceProvider);
    haptic.trigger(HapticType.light);
    
    _liftGraceTimer?.cancel();
    _holdController.stop();
    _holdController.reset();
    _lastHapticStage = 0;

    setState(() {
      _state = GameState.waiting;
      _activeFingers.clear();
      _selectedPointerId = null;
      _currentlyHighlightedId = null;
      _generateDare();
    });
  }

  Color _getNextAvailableColor() {
    final usedColors = _activeFingers.values.map((f) => f.color).toSet();
    for (final color in _neonPalette) {
      if (!usedColors.contains(color)) {
        return color;
      }
    }
    return _neonPalette[_activeFingers.length % _neonPalette.length];
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_state == GameState.finished) {
      _resetGame();
      return;
    }
    if (_state == GameState.spinning) return;

    _liftGraceTimer?.cancel(); // Cancel any pending lift cancellation

    final haptic = ref.read(hapticServiceProvider);
    haptic.trigger(HapticType.light);

    setState(() {
      final color = _getNextAvailableColor();
      _activeFingers[event.pointer] = FingerPoint(
        id: event.pointer,
        position: event.position,
        color: color,
        playerNumber: _activeFingers.length + 1,
      );
    });

    _checkHoldState();
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_state == GameState.spinning || _state == GameState.finished) return;
    if (_activeFingers.containsKey(event.pointer)) {
      final oldPos = _activeFingers[event.pointer]!.position;
      // Filter out micro-jitter under 3px to avoid frame drops
      if ((oldPos - event.position).distanceSquared > 9) {
        setState(() {
          _activeFingers[event.pointer]!.position = event.position;
        });
      }
    }
  }

  void _onPointerUp(PointerEvent event) {
    if (_state == GameState.spinning || _state == GameState.finished) return;
    
    setState(() {
      _activeFingers.remove(event.pointer);
    });

    // Use a short 120ms grace period so natural finger jitter/bounce doesn't violently cancel
    if (_activeFingers.length < 2 && _state == GameState.holding) {
      _liftGraceTimer?.cancel();
      _liftGraceTimer = Timer(const Duration(milliseconds: 120), () {
        if (mounted && _activeFingers.length < 2 && _state == GameState.holding) {
          _holdController.stop();
          _holdController.reset();
          _lastHapticStage = 0;
          setState(() {
            _state = GameState.waiting;
          });
          ref.read(hapticServiceProvider).trigger(HapticType.light);
        }
      });
    } else {
      _checkHoldState();
    }
  }

  void _checkHoldState() {
    if (_activeFingers.length >= 2) {
      _liftGraceTimer?.cancel();
      if (_state != GameState.holding) {
        setState(() {
          _state = GameState.holding;
          _lastHapticStage = 0;
        });
        _holdController.forward(from: 0.0);
      }
    } else if (_activeFingers.isEmpty) {
      _liftGraceTimer?.cancel();
      _holdController.stop();
      _holdController.reset();
      _lastHapticStage = 0;
      if (_state == GameState.holding) {
        setState(() {
          _state = GameState.waiting;
        });
      }
    }
  }

  Future<void> _startSpinning() async {
    if (!mounted) return;

    final pointerIds = _activeFingers.keys.toList();
    if (pointerIds.length < 2) {
      _resetGame();
      return;
    }

    setState(() {
      _state = GameState.spinning;
    });

    final haptic = ref.read(hapticServiceProvider);
    final audio = ref.read(audioServiceProvider);
    haptic.trigger(HapticType.heavy);
    audio.play(GameSound.countdownGo);

    final random = Random();
    final int maxSpins = 24 + random.nextInt(12);
    
    int delayMs = 45;

    for (int i = 0; i < maxSpins; i++) {
      if (!mounted) return;
      haptic.trigger(HapticType.selection);
      audio.play(GameSound.countdownTick);
      
      setState(() {
        _currentlyHighlightedId = pointerIds[i % pointerIds.length];
      });

      await Future.delayed(Duration(milliseconds: delayMs));
      
      // Decelerate dramatically towards the end
      if (i > maxSpins * 0.75) {
        delayMs += 35;
      } else if (i > maxSpins * 0.5) {
        delayMs += 14;
      } else {
        delayMs += 3;
      }
    }

    if (!mounted) return;
    
    // Final victim chosen!
    haptic.trigger(HapticType.heavy);
    audio.play(GameSound.buzzer);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) haptic.trigger(HapticType.heavy);
    });
    
    setState(() {
      _state = GameState.finished;
      _selectedPointerId = _currentlyHighlightedId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerUp,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Dark futuristic grid
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPatternPainter(),
              ),
            ),

            // Center UI (wrapped in IgnorePointer during active gameplay so it doesn't swallow touches)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: IgnorePointer(
                  ignoring: _state != GameState.finished,
                  child: _buildCenterUI(),
                ),
              ),
            ),

            // Glowing Solid Neon Finger Circles
            ..._activeFingers.values.map((finger) => _buildFingerCircle(finger)),

            // Back button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 24),
                onPressed: () => context.pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterUI() {
    switch (_state) {
      case GameState.waiting:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'TAP ROULETTE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                shadows: [
                  Shadow(
                    color: const Color(0xFF00FFFF).withOpacity(0.9),
                    blurRadius: 25,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF10121C),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.savannaGold.withOpacity(0.8),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.savannaGold.withOpacity(0.2),
                    blurRadius: 25,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                _currentDare,
                textAlign: TextAlign.center,
                style: AppTypography.h3.copyWith(
                  color: AppColors.savannaGold,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 36),
            const Icon(Icons.touch_app_rounded, color: Color(0xFF00FFFF), size: 58)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(end: 1.25, duration: 600.ms),
            const SizedBox(height: 16),
            const Text(
              'Hold 2+ fingers anywhere on the screen',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Hold still until the lights start spinning!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 13,
              ),
            ),
          ],
        );
        
      case GameState.holding:
        final progress = _holdController.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'HOLD!',
              style: TextStyle(
                color: const Color(0xFF00FF44),
                fontSize: 68,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
                shadows: [
                  Shadow(color: const Color(0xFF00FF44).withOpacity(0.9), blurRadius: 40),
                  Shadow(color: Colors.white.withOpacity(0.9), blurRadius: 15),
                ],
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(end: 1.1, duration: 350.ms),
            const SizedBox(height: 12),
            Text(
              'LOCKING IN ${(progress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
          ],
        );
        
      case GameState.spinning:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CHOOSING...',
              style: TextStyle(
                color: const Color(0xFFFF0055),
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                shadows: [
                  Shadow(color: const Color(0xFFFF0055).withOpacity(0.9), blurRadius: 35),
                  Shadow(color: Colors.white.withOpacity(0.9), blurRadius: 15),
                ],
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(end: 1.12, duration: 250.ms),
          ],
        );
        
      case GameState.finished:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "🚨 YOU'RE UP!",
              style: TextStyle(
                color: const Color(0xFFFF0033),
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                shadows: [
                  Shadow(color: const Color(0xFFFF0033).withOpacity(0.9), blurRadius: 40),
                  Shadow(color: Colors.white.withOpacity(0.9), blurRadius: 15),
                ],
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF160D10),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFF0033), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF0033).withOpacity(0.5),
                    blurRadius: 35,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'YOUR DARE / PENALTY:',
                    style: TextStyle(
                      color: Color(0xFFFF0033),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _currentDare,
                    textAlign: TextAlign.center,
                    style: AppTypography.h3.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15, end: 0),
            const SizedBox(height: 36),
            GestureDetector(
              onTap: _resetGame,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF0055), Color(0xFFFF5500)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF0055).withOpacity(0.6),
                      blurRadius: 30,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: const Text(
                  'PLAY AGAIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms).scaleXY(begin: 0.9, end: 1.0),
            const SizedBox(height: 16),
            const Text(
              'Tap anywhere on screen to restart',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        );
    }
  }

  Widget _buildFingerCircle(FingerPoint finger) {
    final bool isHighlighted = _currentlyHighlightedId == finger.id;
    final bool isWinner = _selectedPointerId == finger.id;
    
    // When game finishes, keep only the chosen winner
    if (_state == GameState.finished && !isWinner) {
      return const SizedBox.shrink();
    }

    final double baseDiscSize = isWinner ? 180.0 : (isHighlighted ? 150.0 : 120.0);
    final double pulse = _pulseController.value;

    return Positioned(
      left: finger.position.dx - baseDiscSize / 2,
      top: finger.position.dy - baseDiscSize / 2,
      child: IgnorePointer(
        child: SizedBox(
          width: baseDiscSize,
          height: baseDiscSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Outer shockwave / breathing ripple ring while holding or winner
              if (_state == GameState.holding || isWinner || isHighlighted)
                Container(
                  width: baseDiscSize * (1.15 + pulse * 0.2),
                  height: baseDiscSize * (1.15 + pulse * 0.2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: finger.color.withOpacity(isWinner ? 0.9 : (isHighlighted ? 0.7 : 0.4 * (1 - pulse))),
                      width: isWinner ? 4.5 : 2.5,
                    ),
                  ),
                ),

              // 2. Fully solid, hyper-luminous neon filled circle
              Container(
                width: baseDiscSize * 0.92,
                height: baseDiscSize * 0.92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Solid vivid neon radial gradient: blazing white center fading into pure neon body
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.75,
                    colors: [
                      Colors.white, // Ultra-bright white-hot plasma core
                      Color.lerp(Colors.white, finger.color, 0.4)!,
                      finger.color,
                      finger.color.withOpacity(0.95),
                    ],
                    stops: const [0.0, 0.25, 0.7, 1.0],
                  ),
                  // Multi-layered blinding neon glows
                  boxShadow: [
                    // Layer 1: Core white bloom
                    BoxShadow(
                      color: Colors.white.withOpacity(0.9),
                      blurRadius: isWinner ? 25 : 15,
                      spreadRadius: isWinner ? 6 : 3,
                    ),
                    // Layer 2: Ultra-saturated primary neon halo
                    BoxShadow(
                      color: finger.color,
                      blurRadius: isWinner ? 65 : (isHighlighted ? 48 : 30),
                      spreadRadius: isWinner ? 16 : (isHighlighted ? 10 : 6),
                    ),
                    // Layer 3: Wide ambient neon bloom
                    BoxShadow(
                      color: finger.color.withOpacity(0.9),
                      blurRadius: isWinner ? 110 : (isHighlighted ? 80 : 55),
                      spreadRadius: isWinner ? 30 : (isHighlighted ? 18 : 10),
                    ),
                    // Layer 4: Extreme ambient lighting
                    BoxShadow(
                      color: finger.color.withOpacity(0.6),
                      blurRadius: isWinner ? 160 : 100,
                      spreadRadius: isWinner ? 50 : 25,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'P${finger.playerNumber}',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.85),
                      fontWeight: FontWeight.w900,
                      fontSize: isWinner ? 32 : (isHighlighted ? 26 : 20),
                      shadows: [
                        Shadow(
                          color: Colors.white.withOpacity(0.8),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Neon Charging Progress Ring while holding
              if (_state == GameState.holding)
                CustomPaint(
                  size: Size(baseDiscSize, baseDiscSize),
                  painter: _ChargingArcPainter(
                    progress: _holdController.value,
                    color: finger.color,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws an electric neon charging progress ring around each finger disc
class _ChargingArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ChargingArcPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.48;

    // Glowing track background
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(center, radius, bgPaint);

    // Glowing active progress arc
    final progressPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;

    final glowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      glowPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ChargingArcPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Futuristic tech grid for the dark background
class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E2238).withOpacity(0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 36.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
