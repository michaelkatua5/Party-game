import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/haptic_service.dart';
import '../../../shared/widgets/cheza_button.dart';
import '../../../shared/widgets/cheza_category_card.dart';
import '../../game/providers/game_controller.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/category_providers.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  String _selectedCategoryId = 'sheng';

  void _selectCategory(String id) {
    ref.read(hapticServiceProvider).trigger(HapticType.selection);
    setState(() {
      _selectedCategoryId = id;
    });
  }

  Future<void> _startRound() async {
    ref.read(hapticServiceProvider).trigger(HapticType.success);

    final gameController = ref.read(gameControllerProvider.notifier);
    await gameController.startTurnWithCategory(_selectedCategoryId);

    if (mounted) {
      context.pushReplacement('/game');
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final session = ref.watch(gameControllerProvider);
    final gameController = ref.read(gameControllerProvider.notifier);
    final settings = ref.watch(settingsNotifierProvider);
    final haptic = ref.read(hapticServiceProvider);
    final isDark = settings.isDarkMode;

    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textMain = isDark ? Colors.white : AppColors.textDark;
    final textSub = isDark ? AppColors.textMuted : const Color(0xFF64748B);

    final teams = session?.teams ?? [];
    final currentTeamIndex = session?.currentTeamIndex ?? 0;
    final currentTeamName = session?.currentTeam.name ?? 'Team Simba';
    final currentRoundNum = session?.currentRound ?? 1;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textMain, size: 20),
          onPressed: () {
            haptic.trigger(HapticType.selection);
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/player-setup');
            }
          },
        ),
        title: Text(
          'CHOOSE YOUR VIBE 🎭',
          style: AppTypography.h2.copyWith(color: textMain, letterSpacing: 1.0),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/player-setup'),
            icon: const Icon(Icons.tune_rounded, size: 16, color: AppColors.savannaGold),
            label: const Text(
              'Edit Teams',
              style: TextStyle(color: AppColors.savannaGold, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Interactive Team Switcher & Round Info
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2A1544), Color(0xFF16102C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.partyPurple.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.partyPurple.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('🦁', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            '$currentTeamName\'s Turn'.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.savannaGold,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'ROUND $currentRoundNum',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Horizontal Interactive Team Selector Chips
                  if (teams.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ...teams.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final team = entry.value;
                            final isCurrent = idx == (currentTeamIndex % teams.length);
                            Color teamColor = AppColors.savannaGold;
                            try {
                              teamColor = Color(int.parse(team.colorHex.replaceFirst('#', '0xFF')));
                            } catch (_) {}

                            return GestureDetector(
                              onTap: () {
                                haptic.trigger(HapticType.selection);
                                gameController.selectTeamIndex(idx);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isCurrent ? teamColor.withOpacity(0.3) : Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isCurrent ? teamColor : Colors.white24,
                                    width: isCurrent ? 2.0 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      idx == 0 ? '🦁' : (idx == 1 ? '🐆' : '⚡'),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      team.name,
                                      style: TextStyle(
                                        color: isCurrent ? Colors.white : Colors.white70,
                                        fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          // Add/Edit Teams Button
                          GestureDetector(
                            onTap: () {
                              haptic.trigger(HapticType.selection);
                              context.push('/player-setup');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add, color: AppColors.savannaGold, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'Edit Teams',
                                    style: TextStyle(
                                      color: AppColors.savannaGold,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // 2. All Categories Grid (2 Columns, Responsive)
            Expanded(
              child: categoriesAsync.when(
                data: (categories) {
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.88,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (ctx, i) {
                      final cat = categories[i];
                      final isSelected = cat.id == _selectedCategoryId;

                      return ChezaCategoryCard(
                        category: cat,
                        isSelected: isSelected,
                        onTap: () => _selectCategory(cat.id),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.savannaGold)),
                error: (err, _) => Center(
                  child: Text('Failed to load packs: $err', style: TextStyle(color: textMain)),
                ),
              ),
            ),

            // 3. Fixed Bottom Bar: Active Vibe + START ROUND CTA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121620) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: ChezaButton(
                  text: 'START ROUND →',
                  variant: ChezaButtonVariant.primary,
                  onPressed: _startRound,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
