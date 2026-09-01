import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../game/providers/game_controller.dart';
import '../../kings_cup/providers/kings_cup_controller.dart';
import '../../profile/providers/profile_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(profileUserProvider);
    final statsAsync = ref.watch(userStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0B1E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar: Profile Pill & Settings Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.savannaGold,
                          child: Text('🙋🏾‍♂️', style: TextStyle(fontSize: 16)),
                        ),
                        const SizedBox(width: 10),
                        userAsync.when(
                          data: (user) => Text(
                            'Hi, ${user.displayName.isNotEmpty ? user.displayName : 'Michael'}!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const Text('Hi, Player!', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white70, size: 24),
                    onPressed: () => context.push('/settings'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Title: "READY TO PLAY?"
              Center(
                child: Text(
                  'READY TO PLAY?',
                  style: AppTypography.displayLarge.copyWith(
                    fontSize: 26,
                    color: AppColors.savannaGold,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 2 Main Hero Games Grid: CHARADES & KINGS CUP
              Row(
                children: [
                  // 1. CHARADES HERO CARD (Purple)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.push('/choose-game'),
                      child: Container(
                        height: 180,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF261947),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6).withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Text('🎭', style: TextStyle(fontSize: 38)),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'CHARADES',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tilt on forehead',
                              style: TextStyle(color: Colors.white60, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // 2. KINGS CUP HERO CARD (Gold)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(kingsCupControllerProvider.notifier).startNewGame();
                        context.push('/kings-cup');
                      },
                      child: Container(
                        height: 180,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF332308),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.savannaGold, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.savannaGold.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.savannaGold.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Text('👑', style: TextStyle(fontSize: 38)),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'KINGS CUP',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Card drinking game',
                              style: TextStyle(color: Colors.white60, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 4 Bottom Navigation Buttons matching Blueprint Screen 2
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickAction(
                    icon: Icons.people_alt_rounded,
                    label: 'PLAYERS',
                    color: const Color(0xFF10B981),
                    onTap: () => context.push('/player-setup'),
                  ),
                  _buildQuickAction(
                    icon: Icons.grid_view_rounded,
                    label: 'CATEGORIES',
                    color: const Color(0xFFF97316),
                    onTap: () => context.push('/categories'),
                  ),
                  _buildQuickAction(
                    icon: Icons.emoji_events_rounded,
                    label: 'ACHIEVEMENTS',
                    color: AppColors.savannaGold,
                    onTap: () => context.push('/profile'),
                  ),
                  _buildQuickAction(
                    icon: Icons.settings,
                    label: 'SETTINGS',
                    color: const Color(0xFF8B5CF6),
                    onTap: () => context.push('/settings'),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Bottom Banner: Last Game Result Card
              statsAsync.when(
                data: (stats) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1530),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF2E2452)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.savannaGold.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🏆', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'LAST GAME',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            const Text(
                              'TEAM MWAKA 18 - 14 WIN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white38),
                    ],
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1530),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.4), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
