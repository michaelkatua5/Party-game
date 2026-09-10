import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/haptic_service.dart';
import '../../../domain/models/player.dart';
import '../providers/kings_cup_controller.dart';
import 'package:uuid/uuid.dart';

class KingsCupSetupScreen extends ConsumerStatefulWidget {
  const KingsCupSetupScreen({super.key});

  @override
  ConsumerState<KingsCupSetupScreen> createState() => _KingsCupSetupScreenState();
}

class _KingsCupSetupScreenState extends ConsumerState<KingsCupSetupScreen> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final List<Player> _players = [];

  final _quickNames = ['Alex', 'Jordan', 'Sam', 'Morgan', 'Riley', 'Casey', 'Taylor', 'Drew'];

  void _addPlayer([String? name]) {
    final n = (name ?? _textController.text).trim();
    if (n.isEmpty) return;
    if (_players.any((p) => p.name.toLowerCase() == n.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Player already added!'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() {
      _players.add(Player(id: const Uuid().v4(), name: n));
    });
    if (name == null) {
      _textController.clear();
      _focusNode.requestFocus();
    }
  }

  void _removePlayer(int index) {
    setState(() => _players.removeAt(index));
  }

  void _startGame() {
    if (_players.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least 2 players to start!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    ref.read(hapticServiceProvider).trigger(HapticType.success);
    ref.read(kingsCupControllerProvider.notifier).startNewGame(
      players: _players,
      isFamilyMode: false,
    );
    context.push('/kings-cup');
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'KINGS CUP 👑',
          style: AppTypography.h2.copyWith(letterSpacing: 1.2, color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [
              Color(0xFF3D2A00),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Rule reminder card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.savannaGold.withOpacity(0.15),
                        AppColors.savannaGold.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.savannaGold.withOpacity(0.4)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '👑 HOW IT WORKS',
                        style: TextStyle(
                          color: AppColors.savannaGold,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Draw a card from the deck\n• Each card has a rule or dare\n• 4 Kings = 4 drinks from the King\'s Cup\n• Last king drawn has to finish the cup!',
                        style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Players section header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ADD PLAYERS',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.savannaGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.savannaGold.withOpacity(0.4)),
                      ),
                      child: Text(
                        '${_players.length} player${_players.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: AppColors.savannaGold,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Input row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: 'Player name',
                          hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                          filled: true,
                          fillColor: const Color(0xFF1A1A00),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.white12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.savannaGold, width: 2),
                          ),
                        ),
                        onSubmitted: (_) => _addPlayer(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _addPlayer(),
                      child: Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: AppColors.savannaGold,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: AppColors.savannaGold.withOpacity(0.4), blurRadius: 12),
                          ],
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.black, size: 26),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Quick add chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _quickNames
                        .where((n) => !_players.any((p) => p.name == n))
                        .map((n) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                backgroundColor: const Color(0xFF1A1A00),
                                side: BorderSide(color: AppColors.savannaGold.withOpacity(0.3)),
                                label: Text(
                                  '+ $n',
                                  style: const TextStyle(
                                    color: AppColors.savannaGold,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                                onPressed: () => _addPlayer(n),
                              ),
                            ))
                        .toList(),
                  ),
                ),

                const SizedBox(height: 14),

                // Player list
                if (_players.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A00),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Center(
                      child: Text(
                        'No players yet.\nAdd at least 2 to start!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white38, fontSize: 13),
                      ),
                    ),
                  )
                else
                  ..._players.asMap().entries.map((e) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A00),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.savannaGold.withOpacity(0.25)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.savannaGold.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.savannaGold.withOpacity(0.5)),
                            ),
                            child: Center(
                              child: Text(
                                '${e.key + 1}',
                                style: const TextStyle(
                                  color: AppColors.savannaGold,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              e.value.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 20),
                            onPressed: () => _removePlayer(e.key),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.1, end: 0);
                  }),

                const SizedBox(height: 28),

                // Start button
                GestureDetector(
                  onTap: _startGame,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.savannaGold,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.savannaGold.withOpacity(0.45),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'DEAL THE CARDS 👑',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
