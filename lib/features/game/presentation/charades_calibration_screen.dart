import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/tilt_sensor_service.dart';
import '../../../domain/models/game_settings.dart';
import '../../../domain/models/team.dart';
import '../../players/providers/player_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/game_controller.dart';

class CharadesCalibrationScreen extends ConsumerStatefulWidget {
  const CharadesCalibrationScreen({super.key});

  @override
  ConsumerState<CharadesCalibrationScreen> createState() =>
      _CharadesCalibrationScreenState();
}

class _CharadesCalibrationScreenState
    extends ConsumerState<CharadesCalibrationScreen> {
  final TiltSensorService _tiltSensor = TiltSensorService();
  double _progress = 0.0;
  bool _sensorUnavailable = false;
  bool _isCalibrating = true;

  @override
  void initState() {
    super.initState();
    _startRealCalibration();
  }

  Future<void> _startRealCalibration() async {
    setState(() {
      _isCalibrating = true;
      _sensorUnavailable = false;
      _progress = 0.0;
    });

    final success = await _tiltSensor.startCalibration(
      onProgress: (p) {
        if (mounted) setState(() => _progress = p);
      },
    );

    if (!mounted) return;

    if (success) {
      setState(() => _isCalibrating = false);
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        _launchGame(TiltControlMode.tilt);
      }
    } else {
      setState(() {
        _isCalibrating = false;
        _sensorUnavailable = true;
      });
    }
  }

  Future<void> _launchGame(TiltControlMode controlMode) async {
    final currentSettings = ref.read(settingsNotifierProvider);
    final players = ref.read(sharedPlayersProvider);

    final updatedSettings = currentSettings.copyWith(controlMode: controlMode);
    await ref.read(settingsNotifierProvider.notifier).updateSettings(updatedSettings);

    // Build balanced teams from shared player list
    final teamA = Team(
      id: 'team_a',
      name: 'TEAM MWAKA',
      colorHex: '#FB8500',
      players: players.isNotEmpty ? players : [players.first],
    );

    await ref.read(gameControllerProvider.notifier).startCustomGame(
          settings: updatedSettings,
          teams: [teamA],
        );

    if (mounted) {
      context.go('/game');
    }
  }

  @override
  void dispose() {
    _tiltSensor.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0B1E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Title Header
              Text(
                'PUT YOUR PHONE\nON YOUR FOREHEAD',
                textAlign: TextAlign.center,
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Screen facing your friends.\nKeep it straight.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.3),
              ),

              const SizedBox(height: 36),

              // Boy with phone on forehead illustration
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E1736),
                  border: Border.all(
                    color: _sensorUnavailable ? AppColors.coralRed : const Color(0xFF8B5CF6),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: _sensorUnavailable ? AppColors.coralRed : const Color(0xFF8B5CF6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _sensorUnavailable ? 'TAP MODE' : '📱 SCREEN OUT',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _sensorUnavailable ? '👆' : '👦🏾',
                      style: const TextStyle(fontSize: 64),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              if (_sensorUnavailable) ...[
                // Sensor Unavailable Notice & Tap Mode Fallback
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.coralRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.coralRed.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: const [
                      Text(
                        'Sensors Unavailable',
                        style: TextStyle(color: AppColors.coralRed, fontWeight: FontWeight.w900, fontSize: 15),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'No accelerometer detected on this device. You can play using on-screen Tap Buttons!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => _launchGame(TiltControlMode.tap),
                    child: const Text(
                      'START IN TAP MODE 👆',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1),
                    ),
                  ),
                ),
              ] else ...[
                // Calibrating status & progress
                const Text(
                  'CALIBRATING...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: 220,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _progress.clamp(0.0, 1.0),
                      minHeight: 10,
                      backgroundColor: const Color(0xFF1F1B33),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Keep still',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),

                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _launchGame(TiltControlMode.tap),
                  child: const Text(
                    'Or Play in Tap Mode',
                    style: TextStyle(color: AppColors.savannaGold, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
