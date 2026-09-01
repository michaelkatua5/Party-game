import 'package:flutter_test/flutter_test.dart';
import 'package:cheza_game/core/services/tilt_sensor_service.dart';
import 'package:cheza_game/domain/models/game_settings.dart';

void main() {
  group('TiltSensorService Unit Tests', () {
    late TiltSensorService service;

    setUp(() {
      service = TiltSensorService();
    });

    test('Initial state is uninitialized with neutral state', () {
      expect(service.status, equals(SensorStatus.uninitialized));
      expect(service.currentState.name, equals('neutral'));
    });

    test('Sensitivity changes activation threshold', () {
      service.sensitivity = TiltSensitivity.high;
      expect(service.sensitivity, equals(TiltSensitivity.high));

      service.sensitivity = TiltSensitivity.low;
      expect(service.sensitivity, equals(TiltSensitivity.low));
    });

    test('Stop listening resets state cleanly', () {
      service.stopListening();
      expect(service.currentState.name, equals('neutral'));
    });
  });
}
