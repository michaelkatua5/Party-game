import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimerState {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;
  final bool isPaused;

  const TimerState({
    required this.remainingSeconds,
    required this.totalSeconds,
    this.isRunning = false,
    this.isPaused = false,
  });

  bool get isTimeUp => remainingSeconds <= 0;
}

final timerNotifierProvider =
    StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier();
});

class TimerNotifier extends StateNotifier<TimerState> {
  Timer? _timer;
  void Function()? onTimeUp;
  void Function(int remaining)? onTick;

  TimerNotifier()
      : super(const TimerState(remainingSeconds: 60, totalSeconds: 60));

  void startTimer({
    required int durationSeconds,
    void Function()? onCompleted,
    void Function(int remaining)? onSecondTick,
  }) {
    _timer?.cancel();
    onTimeUp = onCompleted;
    onTick = onSecondTick;

    state = TimerState(
      remainingSeconds: durationSeconds,
      totalSeconds: durationSeconds,
      isRunning: true,
      isPaused: false,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 1) {
        final next = state.remainingSeconds - 1;
        state = TimerState(
          remainingSeconds: next,
          totalSeconds: state.totalSeconds,
          isRunning: true,
          isPaused: false,
        );
        onTick?.call(next);
      } else {
        _timer?.cancel();
        state = TimerState(
          remainingSeconds: 0,
          totalSeconds: state.totalSeconds,
          isRunning: false,
          isPaused: false,
        );
        onTimeUp?.call();
      }
    });
  }

  void pauseTimer() {
    if (state.isRunning && !state.isPaused) {
      _timer?.cancel();
      state = TimerState(
        remainingSeconds: state.remainingSeconds,
        totalSeconds: state.totalSeconds,
        isRunning: false,
        isPaused: true,
      );
    }
  }

  void resumeTimer() {
    if (state.isPaused && state.remainingSeconds > 0) {
      startTimer(
        durationSeconds: state.remainingSeconds,
        onCompleted: onTimeUp,
        onSecondTick: onTick,
      );
    }
  }

  void stopTimer() {
    _timer?.cancel();
    state = TimerState(
      remainingSeconds: state.totalSeconds,
      totalSeconds: state.totalSeconds,
      isRunning: false,
      isPaused: false,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
