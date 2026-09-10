import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/cheza_card.dart';
import '../providers/leaderboard_provider.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  int _activeTab = 0; // 0: Global, 1: Squad, 2: Weekly

  @override
  Widget build(BuildContext context) {
    final leaderboardAsync = ref.watch(leaderboardEntriesProvider);

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
          'LEADERBOARD',
          style: AppTypography.h2.copyWith(letterSpacing: 1.2),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Segmented Timeframe Switcher
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.darkCardBorder),
                ),
                child: Row(
                  children: [
                    _buildTabButton('Global 🌍', 0),
                    _buildTabButton('Squad 👥', 1),
                    _buildTabButton('Weekly 🔥', 2),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Visual Top 3 Podium
              leaderboardAsync.when(
                data: (entries) {
                  if (entries.length < 3) return const SizedBox.shrink();
                  final first = entries[0];
                  final second = entries[1];
                  final third = entries[2];

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // #2 Silver Podium
                      _buildPodiumColumn(
                        rank: 2,
                        name: second.playerName,
                        avatar: second.avatar ?? '🙆🏾‍♀️',
                        score: second.score,
                        height: 110,
                        color: const Color(0xFFCBD5E1),
                      ),
                      const SizedBox(width: 12),

                      // #1 Gold Podium
                      _buildPodiumColumn(
                        rank: 1,
                        name: first.playerName,
                        avatar: first.avatar ?? '👑',
                        score: first.score,
                        height: 140,
                        color: AppColors.savannaGold,
                        isFirst: true,
                      ),
                      const SizedBox(width: 12),

                      // #3 Bronze Podium
                      _buildPodiumColumn(
                        rank: 3,
                        name: third.playerName,
                        avatar: third.avatar ?? '🧑🏾',
                        score: third.score,
                        height: 90,
                        color: const Color(0xFFD97706),
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
                },
                loading: () => const SizedBox(height: 140),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 28),

              // Remaining Rankings List
              leaderboardAsync.when(
                data: (entries) => Column(
                  children: List.generate(entries.length, (i) {
                    final entry = entries[i];
                    return ChezaCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            alignment: Alignment.center,
                            child: Text(
                              '#${i + 1}',
                              style: TextStyle(
                                color: i < 3 ? AppColors.savannaGold : Colors.white38,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.darkInput,
                            child: Text(entry.avatar ?? '🧑🏾', style: const TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              entry.playerName,
                              style: AppTypography.h3.copyWith(fontSize: 15),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.savannaGold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${entry.score} pts',
                              style: AppTypography.buttonMedium.copyWith(
                                color: AppColors.savannaGold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.savannaGold),
                ),
                error: (_, __) => const Center(
                  child: Text('Failed to load leaderboard', style: TextStyle(color: Colors.white60)),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.savannaGold : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.textDark : Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumColumn({
    required int rank,
    required String name,
    required String avatar,
    required int score,
    required double height,
    required Color color,
    bool isFirst = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFirst) ...[
          const Text('👑', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
        ],
        CircleAvatar(
          radius: isFirst ? 26 : 22,
          backgroundColor: color.withOpacity(0.2),
          child: Text(avatar, style: TextStyle(fontSize: isFirst ? 26 : 20)),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 80,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.buttonMedium.copyWith(fontSize: 12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$score pts',
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          width: 88,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.18),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            '#$rank',
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
