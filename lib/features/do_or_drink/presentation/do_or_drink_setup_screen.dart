import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/haptic_service.dart';
import '../../../domain/models/player.dart';
import '../providers/do_or_drink_provider.dart';
import 'package:uuid/uuid.dart';

class DoOrDrinkSetupScreen extends ConsumerStatefulWidget {
  const DoOrDrinkSetupScreen({super.key});

  @override
  ConsumerState<DoOrDrinkSetupScreen> createState() => _DoOrDrinkSetupScreenState();
}

class _DoOrDrinkSetupScreenState extends ConsumerState<DoOrDrinkSetupScreen> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final List<Player> _players = [];
  String _selectedMode = 'friendly';

  final _modes = [
    {
      'id': 'friendly',
      'emoji': '😊',
      'label': 'FRIENDLY',
      'desc': 'Wholesome & feel-good',
      'color': const Color(0xFF38BDF8),
      'gradient': [const Color(0xFF0C4A6E), const Color(0xFF082F49)],
    },
    {
      'id': 'mild',
      'emoji': '😏',
      'label': 'MILD',
      'desc': 'Fun laughs & light dares',
      'color': AppColors.savannaGold,
      'gradient': [const Color(0xFF713F12), const Color(0xFF431407)],
    },
    {
      'id': 'spicy',
      'emoji': '🌶️',
      'label': 'SPICY',
      'desc': 'Adults only – 21+',
      'color': const Color(0xFFFF2A6D),
      'gradient': [const Color(0xFF7F1D1D), const Color(0xFF450A0A)],
    },
  ];

  void _addPlayer() {
    final name = _textController.text.trim();
    if (name.isEmpty) return;
    if (_players.any((p) => p.name.toLowerCase() == name.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Player already added!'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() {
      _players.add(Player(id: const Uuid().v4(), name: name));
    });
    _textController.clear();
    _focusNode.requestFocus();
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
    ref.read(doOrDrinkControllerProvider.notifier).startNewGame(
      players: _players,
      mode: _selectedMode,
    );
    context.push('/do-or-drink');
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedModeData = _modes.firstWhere((m) => m['id'] == _selectedMode);
    final themeColor = selectedModeData['color'] as Color;

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
          'DO OR DRINK 🍻',
          style: AppTypography.h2.copyWith(letterSpacing: 1.2, color: Colors.white),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [
              themeColor.withOpacity(0.2),
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
                // Mode selector
                const Text(
                  'CHOOSE YOUR VIBE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: _modes.map((mode) {
                    final isSelected = _selectedMode == mode['id'];
                    final color = mode['color'] as Color;
                    final gradientColors = mode['gradient'] as List<Color>;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          ref.read(hapticServiceProvider).trigger(HapticType.selection);
                          setState(() => _selectedMode = mode['id'] as String);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isSelected ? gradientColors : [const Color(0xFF1A1A2E), const Color(0xFF111122)],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected ? color : Colors.white12,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: color.withOpacity(0.35), blurRadius: 16, spreadRadius: 1)]
                                : [],
                          ),
                          child: Column(
                            children: [
                              Text(mode['emoji'] as String, style: const TextStyle(fontSize: 28)),
                              const SizedBox(height: 6),
                              Text(
                                mode['label'] as String,
                                style: TextStyle(
                                  color: isSelected ? color : Colors.white60,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                mode['desc'] as String,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected ? Colors.white70 : Colors.white38,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 28),

                // Players section
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
                        color: themeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: themeColor.withOpacity(0.4)),
                      ),
                      child: Text(
                        '${_players.length} player${_players.length == 1 ? '' : 's'}',
                        style: TextStyle(color: themeColor, fontWeight: FontWeight.w800, fontSize: 11),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Input
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
                          fillColor: const Color(0xFF1A1A2E),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: themeColor.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.white12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: themeColor, width: 2),
                          ),
                        ),
                        onSubmitted: (_) => _addPlayer(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _addPlayer,
                      child: Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: themeColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: themeColor.withOpacity(0.4), blurRadius: 12),
                          ],
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.black, size: 26),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Player list
                if (_players.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
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
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: themeColor.withOpacity(0.25)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: themeColor.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: themeColor.withOpacity(0.5)),
                            ),
                            child: Center(
                              child: Text(
                                '${e.key + 1}',
                                style: TextStyle(color: themeColor, fontWeight: FontWeight.w900, fontSize: 15),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              e.value.name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 60,
                    decoration: BoxDecoration(
                      color: themeColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(color: themeColor.withOpacity(0.45), blurRadius: 20, spreadRadius: 2),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'LET\'S PLAY 🍻',
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
