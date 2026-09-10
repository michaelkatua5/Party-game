import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/game_settings.dart';
import '../../settings/providers/settings_provider.dart';

class GameSettingsSheet extends ConsumerStatefulWidget {
  const GameSettingsSheet({super.key});

  @override
  ConsumerState<GameSettingsSheet> createState() => _GameSettingsSheetState();
}

class _GameSettingsSheetState extends ConsumerState<GameSettingsSheet> {
  late int _roundTime;
  late String _difficulty;
  late bool _sound;
  late bool _haptics;
  late bool _showPassCount;
  late bool _isPartyMode;
  late TiltControlMode _controlMode;
  late TiltSensitivity _sensitivity;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsNotifierProvider);
    _roundTime = settings.roundDurationSeconds;
    _difficulty = settings.difficulty;
    _sound = settings.soundEnabled;
    _haptics = settings.hapticsEnabled;
    _showPassCount = settings.showPassCount;
    _isPartyMode = settings.drinkingMode;
    _controlMode = settings.controlMode;
    _sensitivity = settings.sensitivity;
  }

  void _saveSettings() {
    final notifier = ref.read(settingsNotifierProvider.notifier);
    final updated = ref.read(settingsNotifierProvider).copyWith(
          roundDurationSeconds: _roundTime,
          difficulty: _difficulty,
          soundEnabled: _sound,
          hapticsEnabled: _haptics,
          showPassCount: _showPassCount,
          drinkingMode: _isPartyMode,
          familyFriendlyMode: !_isPartyMode,
          controlMode: _controlMode,
          sensitivity: _sensitivity,
        );
    notifier.updateSettings(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF161229),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'GAME SETTINGS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 1. Game Mode (Party / Family)
            _buildSectionLabel('GAME MODE'),
            Row(
              children: [
                _buildSegmentPill(
                  label: 'Party Mode 🍻',
                  isSelected: _isPartyMode,
                  onTap: () => setState(() => _isPartyMode = true),
                ),
                const SizedBox(width: 10),
                _buildSegmentPill(
                  label: 'Family Friendly 👨‍👩‍👧',
                  isSelected: !_isPartyMode,
                  onTap: () => setState(() => _isPartyMode = false),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 2. Control Method (Tilt Mode / Tap Mode)
            _buildSectionLabel('CONTROL METHOD'),
            Row(
              children: [
                _buildSegmentPill(
                  label: 'Forehead Tilt 📱',
                  isSelected: _controlMode == TiltControlMode.tilt,
                  onTap: () => setState(() => _controlMode = TiltControlMode.tilt),
                ),
                const SizedBox(width: 10),
                _buildSegmentPill(
                  label: 'Tap Buttons 👆',
                  isSelected: _controlMode == TiltControlMode.tap,
                  onTap: () => setState(() => _controlMode = TiltControlMode.tap),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 3. Round Time (15s, 30s, 45s, 60s)
            _buildSectionLabel('ROUND TIME'),
            Row(
              children: [15, 30, 45, 60].map((t) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _buildChoicePill(
                      label: '${t}s',
                      isSelected: _roundTime == t,
                      onTap: () => setState(() => _roundTime = t),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // 4. Difficulty (Easy / Medium / Hard)
            _buildSectionLabel('DIFFICULTY'),
            Row(
              children: ['easy', 'medium', 'hard'].map((d) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _buildChoicePill(
                      label: d.toUpperCase(),
                      isSelected: _difficulty == d,
                      onTap: () => setState(() => _difficulty = d),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // 5. Toggles (Sound, Haptics, Pass Count)
            _buildSwitchRow('Sound Effects', _sound, (v) => setState(() => _sound = v)),
            _buildSwitchRow('Haptics Vibration', _haptics, (v) => setState(() => _haptics = v)),
            _buildSwitchRow('Show Pass Count', _showPassCount, (v) => setState(() => _showPassCount = v)),

            const SizedBox(height: 20),

            // Save / Start Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _saveSettings,
                child: const Text(
                  'SAVE SETTINGS',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white54,
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSegmentPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF221C38),
            borderRadius: BorderRadius.circular(14),
            border: isSelected ? null : Border.all(color: const Color(0xFF332B52)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChoicePill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF221C38),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? null : Border.all(color: const Color(0xFF332B52)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchRow(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Switch(
            value: value,
            activeColor: const Color(0xFF22C55E),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
