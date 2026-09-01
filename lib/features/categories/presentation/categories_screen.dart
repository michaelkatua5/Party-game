import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/game_settings.dart';
import '../../../domain/models/player.dart';
import '../../../domain/models/team.dart';
import '../../../shared/widgets/kenyan_button.dart';
import '../providers/category_providers.dart';
import '../../game/providers/game_controller.dart';
import '../../game_setup/presentation/game_settings_sheet.dart';
import '../../settings/providers/settings_provider.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final Set<String> _selectedCategoryIds = {
    'sheng',
    'food',
    'daily_life',
    'campus',
    'football',
    'music',
  };

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesFutureProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.savannaGold),
            tooltip: 'Game Settings',
            onPressed: () => _openSettingsSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose your categories',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Select the packs you want to appear in the deck',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),

              const SizedBox(height: 20),

              // 3-Column Category Grid matching Blueprint
              Expanded(
                child: categoriesAsync.when(
                  data: (categories) => GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = _selectedCategoryIds.contains(cat.id);
                      final color = Color(int.parse(cat.color.replaceFirst('#', '0xFF')));

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              if (_selectedCategoryIds.length > 1) {
                                _selectedCategoryIds.remove(cat.id);
                              }
                            } else {
                              _selectedCategoryIds.add(cat.id);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withOpacity(0.22) : AppColors.darkCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? color : AppColors.darkCardBorder,
                              width: isSelected ? 2.5 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [],
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _getCategoryEmoji(cat.id),
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                cat.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                                  fontSize: 11,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),

              // Bottom Bar: Count & Start Game Button
              Center(
                child: Text(
                  '${_selectedCategoryIds.length} Categories Selected',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              KenyanButton(
                text: 'START GAME',
                gradient: AppColors.primaryGradient,
                height: 56,
                onPressed: () async {
                  final settings = ref.read(settingsNotifierProvider);
                  final gameSettings = settings.copyWith(
                    selectedCategoryIds: _selectedCategoryIds.toList(),
                  );

                  final teams = [
                    const Team(
                      id: 't1',
                      name: 'TEAM MWAKA',
                      colorHex: '#FB8500',
                      players: [
                        Player(id: 'p1', name: 'Michael'),
                        Player(id: 'p2', name: 'Ivy'),
                        Player(id: 'p3', name: 'Brian'),
                      ],
                    ),
                    const Team(
                      id: 't2',
                      name: 'TEAM SHOSH',
                      colorHex: '#06D6A0',
                      players: [
                        Player(id: 'p4', name: 'Rael'),
                        Player(id: 'p5', name: 'Kevin'),
                        Player(id: 'p6', name: 'Sharon'),
                      ],
                    ),
                  ];

                  await ref.read(gameControllerProvider.notifier).startCustomGame(
                        settings: gameSettings,
                        teams: teams,
                      );

                  if (context.mounted) {
                    context.push('/game');
                  }
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _openSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const GameSettingsSheet(),
    );
  }

  String _getCategoryEmoji(String id) {
    switch (id) {
      case 'sheng':
        return '💬';
      case 'food':
        return '🍗';
      case 'daily_life':
        return '📱';
      case 'campus':
        return '🎓';
      case 'football':
        return '⚽';
      case 'music':
        return '🎵';
      case 'relationships':
        return '💔';
      case 'places':
        return '📍';
      case 'culture':
        return '🇰🇪';
      case 'sherehe':
        return '🍻';
      case 'international':
        return '🌍';
      default:
        return '🎭';
    }
  }
}
