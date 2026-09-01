import 'package:flutter_test/flutter_test.dart';
import 'package:cheza_game/features/game/providers/timer_controller.dart';

void main() {
  group('TimerNotifier Tests', () {
    test('Timer initialization sets remaining and total seconds', () {
      final notifier = TimerNotifier();
      expect(notifier.state.remainingSeconds, equals(60));
      expect(notifier.state.totalSeconds, equals(60));
      expect(notifier.state.isRunning, isFalse);
    });

    test('Starting timer updates state to running', () {
      final notifier = TimerNotifier();
      notifier.startTimer(durationSeconds: 45);

      expect(notifier.state.remainingSeconds, equals(45));
      expect(notifier.state.totalSeconds, equals(45));
      expect(notifier.state.isRunning, isTrue);
      expect(notifier.state.isPaused, isFalse);

      notifier.stopTimer();
    });

    test('Pausing and stopping timer updates state properly', () {
      final notifier = TimerNotifier();
      notifier.startTimer(durationSeconds: 30);
      notifier.pauseTimer();

      expect(notifier.state.isPaused, isTrue);
      expect(notifier.state.isRunning, isFalse);

      notifier.stopTimer();
      expect(notifier.state.isRunning, isFalse);
    });
  });
}
