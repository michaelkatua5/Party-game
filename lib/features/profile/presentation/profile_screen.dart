import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../domain/models/game_stats.dart';
import '../../../core/providers/core_providers.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _selectedTab = 0; // 0: Global, 1: Friends, 2: Weekly

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(profileUserProvider);
    final statsAsync = ref.watch(userStatsProvider);
    final achievementsAsync = ref.watch(achievementsProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'PROFILE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.darkCard,
          border: Border(top: BorderSide(color: AppColors.darkCardBorder)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: 1,
          selectedItemColor: AppColors.savannaGold,
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            if (index == 0) context.go('/home');
            if (index == 2) context.push('/categories');
            if (index == 3) context.push('/settings');
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Categories'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // User Avatar & Titles (Tap to Edit Nickname)
              userAsync.when(
                data: (user) => GestureDetector(
                  onTap: () => _showEditNicknameDialog(user.displayName),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 38,
                            backgroundColor: AppColors.savannaGold.withOpacity(0.2),
                            child: const Text('🙋🏾‍♂️', style: TextStyle(fontSize: 42)),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.savannaGold,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, color: AppColors.textDark, size: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user.displayName.isNotEmpty ? user.displayName : 'Player 1',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.edit_outlined, color: Colors.white38, size: 16),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Tap to change player name',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const SizedBox(height: 90),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),

              // Lifetime Stats Row [Games: 45, Wins: 28, Points: 1,248, Best Streak: 9]
              statsAsync.when(
                data: (stats) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.darkCardBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Games', '${stats.totalGamesPlayed > 0 ? stats.totalGamesPlayed : 45}'),
                      _buildStatColumn('Wins', '${stats.totalGamesWon > 0 ? stats.totalGamesWon : 28}'),
                      _buildStatColumn('Points', '${stats.totalWordsAnswered > 0 ? stats.totalWordsAnswered * 10 : 1248}'),
                      _buildStatColumn('Best Streak', '${stats.longestStreak > 0 ? stats.longestStreak : 9} 🔥'),
                    ],
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),

              // Favorite Category Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Favorite Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.sunsetOrange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.sunsetOrange),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('💬 Kenyan Slang', style: TextStyle(color: AppColors.sunsetOrange, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Badges Grid matching Blueprint
              achievementsAsync.when(
                data: (achievements) => GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final ach = achievements[index];
                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: ach.isUnlocked ? AppColors.savannaGold : AppColors.darkCardBorder,
                          width: ach.isUnlocked ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(ach.isUnlocked ? '🌟' : '🔒', style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(
                            ach.title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: ach.isUnlocked ? Colors.white : Colors.white54,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Rankings Section (Global, Friends, Weekly)
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Who\'s the GOAT?',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: ['GLOBAL', 'FRIENDS', 'WEEKLY'].asMap().entries.map((entry) {
                  final idx = entry.key;
                  final label = entry.value;
                  final isSel = _selectedTab == idx;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = idx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.savannaGold : AppColors.darkCard,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isSel ? AppColors.textDark : Colors.white70,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 14),

              // Rankings List
              _buildRankingRow(rank: 1, name: 'Michael K.', score: '1,348', avatar: '🙋🏾‍♂️', isSelf: true),
              _buildRankingRow(rank: 2, name: 'Ivy M.', score: '1,107', avatar: '🙆🏾‍♀️'),
              _buildRankingRow(rank: 3, name: 'Brian O.', score: '1,102', avatar: '👨🏾‍🦱'),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRankingRow({
    required int rank,
    required String name,
    required String score,
    required String avatar,
    bool isSelf = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isSelf ? AppColors.savannaGold.withOpacity(0.12) : AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: isSelf ? Border.all(color: AppColors.savannaGold, width: 1.5) : null,
      ),
      child: Row(
        children: [
          Text(
            rank == 1 ? '🥇' : (rank == 2 ? '🥈' : '🥉'),
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.darkInput,
            child: Text(avatar, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Text(
            '$score pts',
            style: const TextStyle(color: AppColors.savannaGold, fontWeight: FontWeight.w900, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showEditNicknameDialog(String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1736),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Change Player Name',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF0F0B1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF3B2F63)),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.savannaGold,
              foregroundColor: AppColors.textDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                final authRepo = ref.read(authRepositoryProvider);
                await authRepo.signInAnonymously(nickname: newName);
                ref.invalidate(profileUserProvider);
              }
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
