import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../domain/models/game_settings.dart';

enum TiltAction { correct, pass, none }

enum SensorStatus { uninitialized, calibrating, ready, unavailable }

enum _TiltState { neutral, tiltingUp, tiltingDown, cooldown }

class TiltSensorService {
  StreamSubscription<AccelerometerEvent>? _subscription;
  DateTime _lastTriggerTime = DateTime.now();
  final Duration _cooldownDuration = const Duration(milliseconds: 900);

  SensorStatus _status = SensorStatus.uninitialized;
  SensorStatus get status => _status;

  // Calibrated baseline orientation
  double _baselineZ = 0.0;
  double _baselineY = 9.8;
  int _calibrationSamples = 0;
  double _sumZ = 0.0;
  double _sumY = 0.0;

  _TiltState _state = _TiltState.neutral;
  _TiltState get currentState => _state;

  TiltSensitivity sensitivity = TiltSensitivity.medium;

  double get _activationThresholdRads {
    switch (sensitivity) {
      case TiltSensitivity.high:
        return 0.35; // ~20 degrees
      case TiltSensitivity.medium:
        return 0.52; // ~30 degrees
      case TiltSensitivity.low:
        return 0.73; // ~42 degrees
    }
  }

  // Neutral re-arm threshold: phone must return within ~12 degrees of baseline before firing again
  static const double _neutralResetThresholdRads = 0.22;

  /// Starts real calibration by collecting sensor events over a short duration.
  Future<bool> startCalibration({
    required void Function(double progress) onProgress,
    Duration duration = const Duration(milliseconds: 1600),
  }) async {
    _status = SensorStatus.calibrating;
    _calibrationSamples = 0;
    _sumZ = 0.0;
    _sumY = 0.0;

    final completer = Completer<bool>();
    final stopwatch = Stopwatch()..start();

    try {
      _subscription?.cancel();
      _subscription = accelerometerEvents.listen(
        (event) {
          _calibrationSamples++;
          _sumZ += event.z;
          _sumY += event.y;

          final elapsed = stopwatch.elapsedMilliseconds;
          final progress = (elapsed / duration.inMilliseconds).clamp(0.0, 1.0);
          onProgress(progress);

          if (elapsed >= duration.inMilliseconds && !completer.isCompleted) {
            _subscription?.cancel();
            _subscription = null;

            if (_calibrationSamples >= 5) {
              _baselineZ = _sumZ / _calibrationSamples;
              _baselineY = _sumY / _calibrationSamples;
              _status = SensorStatus.ready;
              _state = _TiltState.neutral;
              completer.complete(true);
            } else {
              _status = SensorStatus.unavailable;
              completer.complete(false);
            }
          }
        },
        onError: (e) {
          if (!completer.isCompleted) {
            _status = SensorStatus.unavailable;
            completer.complete(false);
          }
        },
        cancelOnError: true,
      );

      // Safety timeout in case no sensor events fire at all (e.g. desktop/simulator/web)
      Future.delayed(duration + const Duration(milliseconds: 600), () {
        if (!completer.isCompleted) {
          _subscription?.cancel();
          _subscription = null;
          if (_calibrationSamples >= 5) {
            _baselineZ = _sumZ / _calibrationSamples;
            _baselineY = _sumY / _calibrationSamples;
            _status = SensorStatus.ready;
            _state = _TiltState.neutral;
            completer.complete(true);
          } else {
            _status = SensorStatus.unavailable;
            completer.complete(false);
          }
        }
      });
    } catch (e) {
      _status = SensorStatus.unavailable;
      if (!completer.isCompleted) completer.complete(false);
    }

    return completer.future;
  }

  /// Starts listening during active gameplay with the hysteresis state machine.
  void startActiveGameplayListening({
    required void Function(TiltAction action) onTiltAction,
  }) {
    if (_status == SensorStatus.unavailable) return;

    _state = _TiltState.neutral;
    _lastTriggerTime = DateTime.now();

    try {
      _subscription?.cancel();
      _subscription = accelerometerEvents.listen((event) {
        final now = DateTime.now();

        // Calculate pitch angle deviation from calibrated neutral baseline
        final currentZ = event.z;
        final deltaZ = currentZ - _baselineZ;
        final effectiveY = event.y.abs() > 1.0 ? event.y.abs() : 1.0;
        final deltaAngleRads = atan2(deltaZ, effectiveY);

        // Check if currently in cooldown
        final inCooldown = now.difference(_lastTriggerTime) < _cooldownDuration;

        // State Machine Implementation:
        switch (_state) {
          case _TiltState.neutral:
            if (!inCooldown) {
              // Tilt Down = Nodding down = deltaAngleRads > threshold
              if (deltaAngleRads > _activationThresholdRads) {
                _state = _TiltState.tiltingDown;
                _lastTriggerTime = now;
                onTiltAction(TiltAction.pass);
                _state = _TiltState.cooldown;
              }
              // Tilt Up = Looking up = deltaAngleRads < -threshold
              else if (deltaAngleRads < -_activationThresholdRads) {
                _state = _TiltState.tiltingUp;
                _lastTriggerTime = now;
                onTiltAction(TiltAction.correct);
                _state = _TiltState.cooldown;
              }
            }
            break;

          case _TiltState.cooldown:
          case _TiltState.tiltingUp:
          case _TiltState.tiltingDown:
            // Must return close to calibrated neutral baseline to re-arm the trigger
            if (!inCooldown && deltaAngleRads.abs() < _neutralResetThresholdRads) {
              _state = _TiltState.neutral;
            }
            break;
        }
      }, onError: (e) {
        if (kDebugMode) print('Tilt sensor error: $e');
      });
    } catch (_) {
      // Gracefully handle devices without sensors
    }
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _state = _TiltState.neutral;
  }
}
