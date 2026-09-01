import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/tilt_sensor_service.dart';
import '../../../domain/models/game_session.dart';
import '../../../domain/models/game_settings.dart';
import '../providers/game_controller.dart';
import '../providers/timer_controller.dart';
import 'countdown_overlay.dart';
import 'round_summary_dialog.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  final TiltSensorService _tiltSensor = TiltSensorService();
  bool _showCorrectOverlay = false;
  bool _showPassOverlay = false;
  String? _lastProcessedWordId;

  @override
  void initState() {
    super.initState();
    _startSensorIfApplicable();
  }

  void _startSensorIfApplicable() {
    final session = ref.read(gameControllerProvider);
    if (session == null) return;

    if (session.settings.controlMode == TiltControlMode.tilt) {
      _tiltSensor.sensitivity = session.settings.sensitivity;
      _tiltSensor.startActiveGameplayListening(
        onTiltAction: (action) {
          if (!mounted) return;
          final currentSession = ref.read(gameControllerProvider);
          if (currentSession == null || currentSession.status != GameStatus.playing) {
            return;
          }

          final word = currentSession.currentWord;
          if (word == null || word.id == _lastProcessedWordId) return;

          if (action == TiltAction.correct) {
            _triggerCorrect(word.id);
          } else if (action == TiltAction.pass) {
            _triggerPass(word.id);
          }
        },
      );
    }
  }

  void _triggerCorrect(String wordId) {
    _lastProcessedWordId = wordId;
    ref.read(gameControllerProvider.notifier).onCorrect();
    setState(() => _showCorrectOverlay = true);
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _showCorrectOverlay = false);
    });
  }

  void _triggerPass(String wordId) {
    _lastProcessedWordId = wordId;
    ref.read(gameControllerProvider.notifier).onPass();
    setState(() => _showPassOverlay = true);
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _showPassOverlay = false);
    });
  }

  @override
  void dispose() {
    _tiltSensor.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameControllerProvider);
    final timerState = ref.watch(timerNotifierProvider);

    if (session == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0B1E),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No active game session', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }

    // 1. Countdown state
    if (session.status == GameStatus.countingDown) {
      _tiltSensor.stopListening();
      return CountdownOverlay(
        session: session,
        onCountdownFinished: () {
          ref.read(gameControllerProvider.notifier).beginActiveTurn();
          _startSensorIfApplicable();
        },
      );
    }

    // 2. Round Transition Intermission Scoreboard
    if (session.status == GameStatus.roundTransition) {
      _tiltSensor.stopListening();
      return RoundSummaryDialog(session: session);
    }

    // 3. Completed State -> Redirect to Final Results
    if (session.status == GameStatus.completed) {
      _tiltSensor.stopListening();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/results');
      });
      return const Scaffold(
        backgroundColor: Color(0xFF0F0B1E),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Blueprint Screen 9: Fullscreen Green Correct Feedback Overlay
    if (_showCorrectOverlay) {
      return Scaffold(
        backgroundColor: const Color(0xFF064E3B), // Deep Green
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 72),
              ),
              const SizedBox(height: 24),
              const Text(
                'CORRECT!',
                style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
              const SizedBox(height: 6),
              const Text(
                '+1 POINT',
                style: TextStyle(color: AppColors.savannaGold, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              const Text(
                'NEXT WORD GET READY...',
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1),
              ),
            ],
          ),
        ),
      );
    }

    // Blueprint Screen 10: Fullscreen Red Pass Feedback Overlay
    if (_showPassOverlay) {
      return Scaffold(
        backgroundColor: const Color(0xFF7F1D1D), // Deep Red
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_downward_rounded, color: Colors.white, size: 72),
              ),
              const SizedBox(height: 24),
              const Text(
                'PASS!',
                style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
              const SizedBox(height: 18),
              const Text(
                'NEXT WORD GET READY...',
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1),
              ),
            ],
          ),
        ),
      );
    }

    final currentWord = session.currentWord;
    final currentTeam = session.currentTeam;

    final formattedMinutes = (timerState.remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final formattedSeconds = (timerState.remainingSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: const Color(0xFF0F0B1E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          child: Column(
            children: [
              // Header Row: Score / Team Name / Digital Timer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Score Indicator
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${currentTeam.score}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        'SCORE',
                        style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  // Team & Timer Center Pill
                  Column(
                    children: [
                      Text(
                        currentTeam.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1736),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF3B2F63)),
                        ),
                        child: Text(
                          '$formattedMinutes:$formattedSeconds',
                          style: TextStyle(
                            color: timerState.remainingSeconds <= 10 ? AppColors.coralRed : Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Round number
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${session.currentRound}',
                        style: const TextStyle(
                          color: AppColors.savannaGold,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        'ROUND',
                        style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(flex: 1),

              // Category Badge (e.g. KENYAN SLANG)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currentWord?.categoryId.toUpperCase() ?? 'KENYAN SLANG',
                  style: const TextStyle(
                    color: Color(0xFFC4B5FD),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Main Word Card matching Blueprint Screen 8
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF261947),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  currentWord?.word.toUpperCase() ?? 'MANZE',
                  textAlign: TextAlign.center,
                  style: AppTypography.gameWordCard.copyWith(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Controls matching Blueprint (Both Tilt labels and tap actions)
              Row(
                children: [
                  // TILT UP / GOT IT (Correct)
                  Expanded(
                    child: GestureDetector(
                      onTap: currentWord != null ? () => _triggerCorrect(currentWord.id) : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF064E3B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF22C55E), width: 1.5),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.arrow_upward_rounded, color: Color(0xFF22C55E), size: 24),
                            const SizedBox(height: 4),
                            Text(
                              session.settings.controlMode == TiltControlMode.tap
                                  ? '✓ GOT IT\n(+1 PT)'
                                  : 'TILT UP\nCORRECT',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF22C55E),
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // TILT DOWN / PASS
                  Expanded(
                    child: GestureDetector(
                      onTap: currentWord != null ? () => _triggerPass(currentWord.id) : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7F1D1D),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.arrow_downward_rounded, color: Color(0xFFEF4444), size: 24),
                            const SizedBox(height: 4),
                            Text(
                              session.settings.controlMode == TiltControlMode.tap
                                  ? '↻ PASS\n(SKIP)'
                                  : 'TILT DOWN\nPASS',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
