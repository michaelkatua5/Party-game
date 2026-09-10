import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/widgets/cheza_button.dart';
import '../../../shared/widgets/cheza_card.dart';
import '../../../shared/widgets/cheza_section_header.dart';
import '../../../shared/widgets/cheza_stat_card.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showEditNicknameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Player Name ✏️', style: AppTypography.h2),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter your game nickname',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: AppColors.darkInput,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.darkCardBorder),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ChezaButton(
            text: 'SAVE',
            isFullWidth: false,
            variant: ChezaButtonVariant.primary,
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                final user = await ref.read(profileUserProvider.future);
                final updated = user.copyWith(displayName: newName);
                await ref.read(authRepositoryProvider).updateUserProfile(updated);
                ref.invalidate(profileUserProvider);
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(profileUserProvider);
    final statsAsync = ref.watch(userStatsProvider);
    final achievementsAsync = ref.watch(userAchievementsProvider);

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
          'PROFILE & STATS',
          style: AppTypography.h2.copyWith(letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Avatar Card with Edit action
              userAsync.when(
                data: (user) => ChezaCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.savannaGold.withOpacity(0.18),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.savannaGold.withOpacity(0.5), width: 2),
                        ),
                        child: const Text('🙋🏾‍♂️', style: TextStyle(fontSize: 40)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    user.displayName.isNotEmpty ? user.displayName : 'Kenyan Player',
                                    style: AppTypography.h1.copyWith(fontSize: 20),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: AppColors.savannaGold, size: 18),
                                  onPressed: () => _showEditNicknameDialog(
                                    context,
                                    ref,
                                    user.displayName,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.neonGreen.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'LEVEL 5 • PARTY MVP',
                                style: TextStyle(
                                  color: AppColors.neonGreen,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const SizedBox(height: 100),
                error: (_, __) => const SizedBox.shrink(),
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 20),

              // 4 Core Stats Grid
              statsAsync.when(
                data: (stats) => GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    ChezaStatCard(
                      title: 'GAMES PLAYED',
                      value: '${stats.gamesPlayed}',
                      icon: Icons.sports_esports_rounded,
                      accentColor: AppColors.electricCyan,
                    ),
                    ChezaStatCard(
                      title: 'MATCH WINS',
                      value: '${stats.wins}',
                      icon: Icons.emoji_events_rounded,
                      accentColor: AppColors.savannaGold,
                    ),
                    ChezaStatCard(
                      title: 'CORRECT GUESSES',
                      value: '${stats.totalCorrectAnswers}',
                      icon: Icons.check_circle_rounded,
                      accentColor: AppColors.neonGreen,
                    ),
                    ChezaStatCard(
                      title: 'BEST STREAK',
                      value: '${stats.bestStreak} WINS',
                      icon: Icons.local_fire_department_rounded,
                      accentColor: AppColors.coralRed,
                    ),
                  ],
                ),
                loading: () => const SizedBox(height: 160),
                error: (_, __) => const SizedBox.shrink(),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 24),

              // Achievements Section Header
              const ChezaSectionHeader(
                title: 'UNLOCKED TROPHIES',
                subtitle: 'Badges earned across games & parties',
              ),

              const SizedBox(height: 8),

              // Achievements Grid
              achievementsAsync.when(
                data: (achievements) => Column(
                  children: achievements.map((ach) {
                    final isUnlocked = ach.isUnlocked;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ChezaCard(
                        padding: const EdgeInsets.all(14),
                        borderColor: isUnlocked
                            ? AppColors.savannaGold.withOpacity(0.4)
                            : AppColors.darkCardBorder,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isUnlocked
                                    ? AppColors.savannaGold.withOpacity(0.2)
                                    : Colors.white10,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                ach.icon,
                                style: TextStyle(
                                  fontSize: 22,
                                  color: isUnlocked ? null : Colors.white24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ach.title,
                                    style: AppTypography.h3.copyWith(
                                      fontSize: 14,
                                      color: isUnlocked ? Colors.white : Colors.white38,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    ach.description,
                                    style: AppTypography.bodySmall.copyWith(
                                      fontSize: 11,
                                      color: isUnlocked ? Colors.white70 : Colors.white30,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isUnlocked)
                              const Icon(Icons.check_circle, color: AppColors.savannaGold, size: 20),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.savannaGold),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
