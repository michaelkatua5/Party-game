import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../domain/models/game_session.dart';

class CountdownOverlay extends StatefulWidget {
  final GameSession session;
  final VoidCallback onCountdownFinished;

  const CountdownOverlay({
    super.key,
    required this.session,
    required this.onCountdownFinished,
  });

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> {
  int _countdown = 3;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  Future<void> _startCountdown() async {
    for (int i = 3; i >= 1; i--) {
      if (!mounted) return;
      setState(() => _countdown = i);
      await Future.delayed(const Duration(seconds: 1));
    }
    if (!mounted) return;
    setState(() => _countdown = 0);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      widget.onCountdownFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0B1E),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'GET READY!',
                style: AppTypography.displayLarge.copyWith(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 36),

              // Animated Big Number 3, 2, 1, or START!
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _countdown > 0
                    ? Text(
                        '$_countdown',
                        key: ValueKey(_countdown),
                        style: const TextStyle(
                          fontSize: 120,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF8B5CF6),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'START!',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 48),

              const Text(
                'Tilt UP for CORRECT ⬆️\nTilt DOWN for PASS ⬇️',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
