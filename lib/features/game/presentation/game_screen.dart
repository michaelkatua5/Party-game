import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import 'package:flutter/services.dart';
import '../../../core/services/tilt_sensor_service.dart';
import '../../../domain/models/game_session.dart';
import '../../../domain/models/game_settings.dart';
import '../../../shared/widgets/cheza_button.dart';
import '../../../shared/widgets/cheza_game_card.dart';
import '../../../shared/widgets/cheza_timer_ring.dart';
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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

  void _showPauseDialog() {
    ref.read(timerNotifierProvider.notifier).pause();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Center(
          child: Text(
            'GAME PAUSED ⏸️',
            style: AppTypography.h2.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        content: const Text(
          'Catch your breath! The timer is paused.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ChezaButton(
            text: 'RESUME GAME',
            variant: ChezaButtonVariant.primary,
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(timerNotifierProvider.notifier).resume();
            },
          ),
          const SizedBox(height: 8),
          ChezaButton(
            text: 'QUIT TO HOME',
            variant: ChezaButtonVariant.outline,
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(gameControllerProvider.notifier).resetGame();
              context.go('/home');
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _tiltSensor.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameControllerProvider);
    final timerState = ref.watch(timerNotifierProvider);

    if (session == null) {
      return Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No active game session', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              ChezaButton(
                text: 'Back to Home',
                isFullWidth: false,
                onPressed: () => context.go('/home'),
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
        backgroundColor: AppColors.darkBackground,
        body: Center(child: CircularProgressIndicator(color: AppColors.savannaGold)),
      );
    }

    // Fullscreen Green Correct Feedback Overlay
    if (_showCorrectOverlay) {
      return Scaffold(
        backgroundColor: const Color(0xFF042F1A), // Deep Emerald
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(26),
                decoration: const BoxDecoration(
                  color: AppColors.neonGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: AppColors.textDark, size: 72),
              ).animate().scale(duration: 250.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(
                'CORRECT!',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 40,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.savannaGold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '+1 POINT',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Fullscreen Red Pass Feedback Overlay
    if (_showPassOverlay) {
      return Scaffold(
        backgroundColor: const Color(0xFF450A0A), // Deep Crimson
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(26),
                decoration: const BoxDecoration(
                  color: AppColors.coralRed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_downward_rounded, color: Colors.white, size: 72),
              ).animate().scale(duration: 250.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(
                'PASS!',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 40,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Next word coming up...',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final currentWord = session.currentWord;
    final currentTeam = session.currentTeam;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragEnd: (details) {
          if (currentWord == null || session.status != GameStatus.playing) return;
          if (details.primaryVelocity! < 0) {
            // Swipe Up
            _triggerCorrect(currentWord.id);
          } else if (details.primaryVelocity! > 0) {
            // Swipe Down
            _triggerPass(currentWord.id);
          }
        },
        onTapUp: (details) {
          if (currentWord == null || session.status != GameStatus.playing) return;
          final height = MediaQuery.of(context).size.height;
          if (details.globalPosition.dy < height / 2) {
            _triggerCorrect(currentWord.id);
          } else {
            _triggerPass(currentWord.id);
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingL,
              vertical: AppDimensions.paddingM,
            ),
            child: Column(
              children: [
                // Top Score, Team & Timer Ring Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Team & Score Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.darkCardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentTeam.name.toUpperCase(),
                            style: AppTypography.badge.copyWith(color: AppColors.savannaGold),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '${currentTeam.score}',
                                style: AppTypography.h1.copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'PTS',
                                style: AppTypography.micro.copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Timer Ring Component
                    ChezaTimerRing(
                      remainingSeconds: timerState.remainingSeconds,
                      totalSeconds: session.settings.roundDurationSeconds,
                      size: 68,
                    ),

                    // Pause Button
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.darkCardBorder),
                        ),
                        child: const Icon(Icons.pause_rounded, color: Colors.white, size: 20),
                      ),
                      onPressed: _showPauseDialog,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Physical 3D Active Game Card Component
                Expanded(
                  child: ChezaGameCard(
                    word: currentWord,
                    categoryName: currentWord?.categoryId.toUpperCase() ?? 'KENYAN VIBES',
                    categoryColor: AppColors.savannaGold,
                  ).animate().scale(duration: 200.ms, curve: Curves.easeOutCubic),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
