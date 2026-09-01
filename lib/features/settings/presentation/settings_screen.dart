import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _musicEnabled = true;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL, vertical: 12),
        children: [
          // Section 1: GAME Audio & Sensory
          _buildSectionHeader('GAME'),
          _buildSwitchRow(
            icon: Icons.volume_up_rounded,
            title: 'Sound',
            value: settings.soundEnabled,
            onChanged: (_) => notifier.toggleSound(),
          ),
          _buildSwitchRow(
            icon: Icons.music_note_rounded,
            title: 'Music',
            value: _musicEnabled,
            onChanged: (val) => setState(() => _musicEnabled = val),
          ),
          _buildSwitchRow(
            icon: Icons.vibration_rounded,
            title: 'Haptics',
            value: settings.hapticsEnabled,
            onChanged: (_) => notifier.toggleHaptics(),
          ),

          const SizedBox(height: 24),

          // Section 2: LANGUAGE
          _buildSectionHeader('LANGUAGE'),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildSegmentPill(
                label: 'English',
                isSelected: settings.language == 'en',
                onTap: () => notifier.setLanguage('en'),
              ),
              const SizedBox(width: 10),
              _buildSegmentPill(
                label: 'Kiswahili',
                isSelected: settings.language == 'sw',
                onTap: () => notifier.setLanguage('sw'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section 3: CONTENT FILTERS
          _buildSectionHeader('CONTENT'),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildSegmentPill(
                label: 'Family Friendly',
                isSelected: settings.familyFriendlyMode,
                onTap: () => notifier.toggleFamilyFriendly(),
              ),
              const SizedBox(width: 8),
              _buildSegmentPill(
                label: 'Party Mode',
                isSelected: settings.drinkingMode,
                onTap: () => notifier.toggleDrinkingMode(),
              ),
              const SizedBox(width: 8),
              _buildSegmentPill(
                label: 'Drinking Mode',
                isSelected: settings.drinkingMode,
                onTap: () => notifier.toggleDrinkingMode(),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section 4: ACCOUNT & INFO
          _buildSectionHeader('ACCOUNT'),
          _buildNavRow(
            icon: Icons.person_outline,
            title: 'Profile',
            onTap: () => context.push('/profile'),
          ),
          _buildNavRow(
            icon: Icons.lock_outline,
            title: 'Privacy',
            onTap: () => _showSimpleDialog('Privacy Policy', 'Your game data is saved locally on this device. No personal data is sold.'),
          ),
          _buildNavRow(
            icon: Icons.bar_chart_rounded,
            title: 'Statistics',
            onTap: () => context.push('/profile'),
          ),
          _buildNavRow(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () => _showSimpleDialog('CHEZA! Charades', 'Version 1.0.0 (Build 1)\n\nMade with ❤️ for Kenyan party nights 🇰🇪'),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontWeight: FontWeight.w900,
        fontSize: 12,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.neonGreen,
            onChanged: onChanged,
          ),
        ],
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
            color: isSelected ? AppColors.savannaGold : AppColors.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: isSelected ? null : Border.all(color: AppColors.darkCardBorder),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.textDark : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70, size: 20),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
        onTap: onTap,
      ),
    );
  }

  void _showSimpleDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(content, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: const Text('OK', style: TextStyle(color: AppColors.savannaGold, fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }
}
