import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../players/providers/player_provider.dart';

class PlayerSetupScreen extends ConsumerStatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  ConsumerState<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends ConsumerState<PlayerSetupScreen> {
  final TextEditingController _nameController = TextEditingController();

  void _showAddPlayerDialog({int? editIndex, String? initialName}) {
    if (initialName != null) {
      _nameController.text = initialName;
    } else {
      _nameController.clear();
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1736),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          editIndex == null ? 'Add Player' : 'Edit Player Name',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: 'Enter name (e.g. Wanjiku, Brian)',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF0F0B1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF3B2F63)),
            ),
          ),
          onSubmitted: (_) => _submitPlayer(ctx, editIndex),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _submitPlayer(ctx, editIndex),
            child: Text(editIndex == null ? 'Add' : 'Save', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _submitPlayer(BuildContext ctx, int? editIndex) {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      if (editIndex == null) {
        ref.read(sharedPlayersProvider.notifier).addPlayer(name);
      } else {
        ref.read(sharedPlayersProvider.notifier).editPlayer(editIndex, name);
      }
      _nameController.clear();
    }
    Navigator.of(ctx).pop();
  }

  void _onContinue(List players) {
    if (players.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.coralRed,
          content: const Text(
            'Please add at least 2 players to start the game!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
      _showAddPlayerDialog();
      return;
    }
    context.push('/charades-calibration');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(sharedPlayersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0B1E),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'ADD PLAYERS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL, vertical: 12),
          child: Column(
            children: [
              // Player List or Empty State
              Expanded(
                child: players.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1736),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF3B2F63)),
                              ),
                              child: const Text('👥', style: TextStyle(fontSize: 48)),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Who\'s Playing Tonight?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Add your friends to get the party started!',
                              style: TextStyle(color: Colors.white60, fontSize: 13),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF22C55E),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text(
                                'ADD FIRST PLAYER',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: () => _showAddPlayerDialog(),
                            ),
                          ],
                        ),
                      )
                    : ReorderableListView.builder(
                        itemCount: players.length,
                        onReorder: (oldIdx, newIdx) {
                          ref.read(sharedPlayersProvider.notifier).reorderPlayers(oldIdx, newIdx);
                        },
                        itemBuilder: (context, index) {
                          final p = players[index];
                          return GestureDetector(
                            key: ValueKey(p.id),
                            onTap: () => _showAddPlayerDialog(editIndex: index, initialName: p.name),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1736),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF2E2452)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppColors.savannaGold.withOpacity(0.25),
                                    child: Text(p.avatar ?? '🧑🏾', style: const TextStyle(fontSize: 18)),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const Text(
                                          'Tap to edit name',
                                          style: TextStyle(color: Colors.white38, fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white38, size: 20),
                                    onPressed: () {
                                      ref.read(sharedPlayersProvider.notifier).removePlayer(index);
                                    },
                                  ),
                                  const Icon(Icons.drag_handle_rounded, color: Colors.white24, size: 22),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // "+ ADD PLAYER" Green Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    'ADD PLAYER',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5),
                  ),
                  onPressed: () => _showAddPlayerDialog(),
                ),
              ),

              const SizedBox(height: 12),

              // "CONTINUE" Purple Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'CONTINUE',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1),
                  ),
                  onPressed: () => _onContinue(players),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                '${players.length} ${players.length == 1 ? 'PLAYER' : 'PLAYERS'}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
