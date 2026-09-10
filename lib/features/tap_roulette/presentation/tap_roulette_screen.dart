import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/core_providers.dart';
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

class _TapRouletteScreenState extends ConsumerState<TapRouletteScreen> {
  GameState _state = GameState.waiting;
  final Map<int, FingerPoint> _activeFingers = {};
  Timer? _holdTimer;
  int? _selectedPointerId;
  int? _currentlyHighlightedId;
  String _currentDare = "";

  final List<Color> _playerColors = [
    AppColors.savannaGold,
    AppColors.electricCyan,
    AppColors.cyberPink,
    AppColors.neonGreen,
    AppColors.sunsetOrange,
    AppColors.partyPurple,
    AppColors.coralRed,
    Colors.yellowAccent,
    Colors.lightGreenAccent,
    Colors.deepOrangeAccent,
  ];

  @override
  void initState() {
    super.initState();
    _generateDare();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  void _generateDare() {
    final random = Random();
    _currentDare = tapRoulettePrompts[random.nextInt(tapRoulettePrompts.length)];
  }

  void _resetGame() {
    final haptic = ref.read(hapticServiceProvider);
    haptic.trigger(HapticType.light);
    
    setState(() {
      _state = GameState.waiting;
      _activeFingers.clear();
      _selectedPointerId = null;
      _currentlyHighlightedId = null;
      _generateDare();
    });
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_state == GameState.spinning || _state == GameState.finished) return;

    final haptic = ref.read(hapticServiceProvider);
    haptic.trigger(HapticType.light);

    setState(() {
      final color = _playerColors[_activeFingers.length % _playerColors.length];
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
      setState(() {
        _activeFingers[event.pointer]!.position = event.position;
      });
    }
  }

  void _onPointerUp(PointerEvent event) {
    if (_state == GameState.spinning || _state == GameState.finished) return;
    setState(() {
      _activeFingers.remove(event.pointer);
    });
    _checkHoldState();
  }

  void _checkHoldState() {
    _holdTimer?.cancel();
    if (_activeFingers.length >= 2) {
      setState(() => _state = GameState.holding);
      _holdTimer = Timer(const Duration(milliseconds: 2000), _startSpinning);
    } else {
      setState(() => _state = GameState.waiting);
    }
  }

  Future<void> _startSpinning() async {
    if (!mounted) return;
    
    setState(() {
      _state = GameState.spinning;
    });

    final haptic = ref.read(hapticServiceProvider);
    haptic.trigger(HapticType.heavy);

    final random = Random();
    final int maxSpins = 25 + random.nextInt(15);
    final List<int> pointerIds = _activeFingers.keys.toList();
    
    int delayMs = 40;

    for (int i = 0; i < maxSpins; i++) {
      if (!mounted) return;
      haptic.trigger(HapticType.selection);
      
      setState(() {
        _currentlyHighlightedId = pointerIds[i % pointerIds.length];
      });

      await Future.delayed(Duration(milliseconds: delayMs));
      
      // Decelerate as it gets closer to the end
      if (i > maxSpins * 0.7) {
        delayMs += 35;
      } else if (i > maxSpins * 0.4) {
        delayMs += 10;
      } else {
        delayMs += 2;
      }
    }

    if (!mounted) return;
    
    // Final winner
    haptic.trigger(HapticType.heavy);
    Future.delayed(const Duration(milliseconds: 200), () => haptic.trigger(HapticType.heavy));
    
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
            // Safe back button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white70, size: 28),
                onPressed: () => context.pop(),
              ),
            ),
            
            // Center UI
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: _buildCenterUI(),
              ),
            ),

            // Finger Rings
            ..._activeFingers.values.map((finger) => _buildFingerRing(finger)),
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
            const Text('TAP ROULETTE', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.savannaGold.withOpacity(0.5)),
              ),
              child: Text(
                _currentDare,
                textAlign: TextAlign.center,
                style: AppTypography.h3.copyWith(color: AppColors.savannaGold),
              ),
            ),
            const SizedBox(height: 40),
            const Icon(Icons.touch_app_rounded, color: Colors.white54, size: 48)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(end: 1.1, duration: 800.ms),
            const SizedBox(height: 16),
            const Text(
              'Place your fingers on the screen\n(At least 2 players)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        );
        
      case GameState.holding:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'HOLD!',
              style: TextStyle(
                color: AppColors.neonGreen,
                fontSize: 64,
                fontWeight: FontWeight.w900,
                shadows: [Shadow(color: AppColors.neonGreen.withOpacity(0.5), blurRadius: 20)],
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(end: 1.1, duration: 500.ms),
            const SizedBox(height: 16),
            const Text(
              'Starting soon...',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        );
        
      case GameState.spinning:
        return const SizedBox.shrink(); // Hide UI during spin for dramatic effect
        
      case GameState.finished:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "🍻 YOU'RE UP!",
              style: TextStyle(
                color: AppColors.coralRed,
                fontSize: 48,
                fontWeight: FontWeight.w900,
                shadows: [Shadow(color: AppColors.coralRed.withOpacity(0.5), blurRadius: 20)],
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.coralRed, width: 2),
                boxShadow: [
                  BoxShadow(color: AppColors.coralRed.withOpacity(0.2), blurRadius: 20, spreadRadius: 5),
                ],
              ),
              child: Text(
                _currentDare,
                textAlign: TextAlign.center,
                style: AppTypography.h3.copyWith(color: Colors.white),
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 48),
            GestureDetector(
              onTap: _resetGame,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: AppColors.savannaGold.withOpacity(0.3), blurRadius: 15),
                  ],
                ),
                child: const Text(
                  'PLAY AGAIN',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.2),
                ),
              ),
            ).animate().fadeIn(delay: 600.ms),
          ],
        );
    }
  }

  Widget _buildFingerRing(FingerPoint finger) {
    final bool isHighlighted = _currentlyHighlightedId == finger.id;
    final bool isWinner = _selectedPointerId == finger.id;
    
    // Hide losers
    if (_state == GameState.finished && !isWinner) {
      return const SizedBox.shrink();
    }

    final double size = isWinner ? 180.0 : (isHighlighted ? 130.0 : 100.0);
    final double borderWidth = isWinner ? 10.0 : (isHighlighted ? 8.0 : 4.0);
    final double opacity = isWinner ? 1.0 : (isHighlighted ? 0.9 : 0.6);

    return Positioned(
      left: finger.position.dx - size / 2,
      top: finger.position.dy - size / 2,
      child: IgnorePointer(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutBack,
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: finger.color.withOpacity(opacity),
              width: borderWidth,
            ),
            boxShadow: [
              if (isHighlighted || isWinner)
                BoxShadow(
                  color: finger.color.withOpacity(isWinner ? 0.8 : 0.5),
                  blurRadius: isWinner ? 60 : 30,
                  spreadRadius: isWinner ? 15 : 5,
                )
            ],
          ),
          child: Center(
            child: Text(
              'P${finger.playerNumber}',
              style: TextStyle(
                color: finger.color.withOpacity(opacity),
                fontWeight: FontWeight.w900,
                fontSize: isWinner ? 32 : 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
