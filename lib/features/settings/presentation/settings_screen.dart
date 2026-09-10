import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../domain/models/game_settings.dart';
import '../../../shared/widgets/cheza_card.dart';
import '../../../shared/widgets/cheza_section_header.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'SETTINGS',
          style: AppTypography.h2.copyWith(letterSpacing: 1.2),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. GAMEPLAY & SENSORS
              const ChezaSectionHeader(title: 'GAMEPLAY & SENSORS'),
              ChezaCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSwitchRow(
                      title: 'Forehead Tilt Sensor',
                      subtitle: 'Tilt phone up for correct, down to pass',
                      value: settings.controlMode == TiltControlMode.tilt,
                      onChanged: (val) {
                        notifier.updateSettings(
                          settings.copyWith(
                            controlMode: val ? TiltControlMode.tilt : TiltControlMode.tap,
                          ),
                        );
                      },
                    ),
                    const Divider(color: Colors.white10, height: 20),
                    _buildDropdownRow<TiltSensitivity>(
                      title: 'Sensor Sensitivity',
                      subtitle: 'How far you must tilt your forehead',
                      value: settings.sensitivity,
                      items: const [
                        DropdownMenuItem(value: TiltSensitivity.low, child: Text('Low (±42°)')),
                        DropdownMenuItem(value: TiltSensitivity.medium, child: Text('Medium (±30°)')),
                        DropdownMenuItem(value: TiltSensitivity.high, child: Text('High (±20°)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          notifier.updateSettings(settings.copyWith(sensitivity: val));
                        }
                      },
                    ),
                    const Divider(color: Colors.white10, height: 20),
                    _buildDropdownRow<int>(
                      title: 'Round Duration',
                      subtitle: 'Seconds per player turn',
                      value: settings.roundDurationSeconds,
                      items: const [
                        DropdownMenuItem(value: 45, child: Text('45 Seconds (Fast)')),
                        DropdownMenuItem(value: 60, child: Text('60 Seconds (Standard)')),
                        DropdownMenuItem(value: 90, child: Text('90 Seconds (Relaxed)')),
                        DropdownMenuItem(value: 120, child: Text('120 Seconds (Long)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          notifier.updateSettings(settings.copyWith(roundDurationSeconds: val));
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. AUDIO & HAPTICS
              const ChezaSectionHeader(title: 'AUDIO & HAPTICS'),
              ChezaCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSwitchRow(
                      title: 'Sound Effects',
                      subtitle: 'Countdown beeps, correct chimes & horn',
                      value: settings.soundEnabled,
                      onChanged: (val) => notifier.updateSettings(settings.copyWith(soundEnabled: val)),
                    ),
                    const Divider(color: Colors.white10, height: 20),
                    _buildSwitchRow(
                      title: 'Haptic Vibrations',
                      subtitle: 'Tactile pulses for tilt actions & turns',
                      value: settings.hapticsEnabled,
                      onChanged: (val) => notifier.updateSettings(settings.copyWith(hapticsEnabled: val)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. CONTENT FILTERS
              const ChezaSectionHeader(title: 'CONTENT & PARTY FILTERS'),
              ChezaCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSwitchRow(
                      title: 'Family Friendly Mode',
                      subtitle: 'Filters out drinking and adult party cards',
                      value: settings.familyFriendly,
                      onChanged: (val) => notifier.updateSettings(settings.copyWith(familyFriendly: val)),
                    ),
                    const Divider(color: Colors.white10, height: 20),
                    _buildSwitchRow(
                      title: 'Party & Drinking Forfeits 🍻',
                      subtitle: 'Enable sips penalties for wrong guesses & passes',
                      value: settings.drinkingMode,
                      onChanged: (val) => notifier.updateSettings(settings.copyWith(drinkingMode: val)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4. ABOUT & CREDITS
              const ChezaSectionHeader(title: 'ABOUT CHEZA!'),
              const ChezaCard(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('App Version', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        Text('v2.0.0 (Production)', style: TextStyle(color: AppColors.savannaGold, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    Divider(color: Colors.white10, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Made with ❤️ in Nairobi', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        Text('🇰🇪', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.buttonMedium.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.savannaGold,
          activeTrackColor: AppColors.savannaGold.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildDropdownRow<T>({
    required String title,
    required String subtitle,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.buttonMedium.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
        DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          dropdownColor: const Color(0xFF1B2232),
          style: const TextStyle(color: AppColors.savannaGold, fontSize: 13, fontWeight: FontWeight.bold),
          underline: const SizedBox.shrink(),
        ),
      ],
    );
  }
}
