import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/haptic_service.dart';
import '../../../domain/models/player.dart';
import '../../../domain/models/team.dart';
import '../../../shared/widgets/cheza_button.dart';
import '../../game/providers/game_controller.dart';
import '../../settings/providers/settings_provider.dart';
import '../../kings_cup/providers/kings_cup_controller.dart';
import '../../do_or_drink/providers/do_or_drink_provider.dart';

class PlayerSetupScreen extends ConsumerStatefulWidget {
  final String? targetRoute;
  const PlayerSetupScreen({super.key, this.targetRoute});

  @override
  ConsumerState<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends ConsumerState<PlayerSetupScreen> {
  late bool _isTeamMode;
  final TextEditingController _textController = TextEditingController();

  // Dynamic Teams and Players List
  final List<Team> _teams = [];
  final List<Player> _players = [];

  String _selectedDifficulty = 'all'; // 'easy', 'medium', 'hard', 'all'

  // Quick Squad Name suggestions for fast 1-tap addition
  final List<Map<String, String>> _quickTeamSuggestions = [
    {'name': 'Simba', 'emoji': '🦁', 'color': '#FFB800'},
    {'name': 'Chui', 'emoji': '🐆', 'color': '#00F0FF'},
    {'name': 'Mwitu', 'emoji': '🌿', 'color': '#2ED573'},
    {'name': 'Kifaru', 'emoji': '🦏', 'color': '#FF007F'},
    {'name': 'Nyati', 'emoji': '🦬', 'color': '#A855F7'},
    {'name': 'Harambee', 'emoji': '⚡', 'color': '#FF9900'},
  ];

  static const List<String> _emojis = ['🙋🏾‍♂️', '🙆🏾‍♀️', '🦁', '🐆', '🔥', '👑', '⚡', '🇰🇪', '🎭', '🥑'];

  @override
  void initState() {
    super.initState();
    _isTeamMode = widget.targetRoute == '/kings-cup' ? false : true;
    final settings = ref.read(settingsNotifierProvider);
    _selectedDifficulty = settings.difficulty;
  }

  void _addCustomEntry() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    ref.read(hapticServiceProvider).trigger(HapticType.light);
    setState(() {
      if (_isTeamMode) {
        final newTeamId = 'team_${_teams.length + 1}';
        final colors = ['#FFB800', '#00F0FF', '#FF007F', '#2ED573', '#A855F7'];
        final color = colors[_teams.length % colors.length];
        final name = text.startsWith('Team ') ? text : 'Team $text';
        _teams.add(
          Team(
            id: newTeamId,
            name: name,
            colorHex: color,
            players: [Player(id: const Uuid().v4(), name: 'Player 1')],
          ),
        );
      } else {
        final emoji = _emojis[_players.length % _emojis.length];
        _players.add(Player(id: const Uuid().v4(), name: text, avatar: emoji));
      }
      _textController.clear();
    });
  }

  void _addSuggestedTeam(String name, String colorHex) {
    ref.read(hapticServiceProvider).trigger(HapticType.light);
    setState(() {
      final teamName = 'Team $name';
      if (_teams.any((t) => t.name.toLowerCase() == teamName.toLowerCase())) {
        return;
      }
      _teams.add(
        Team(
          id: 'team_${_teams.length + 1}',
          name: teamName,
          colorHex: colorHex,
          players: [Player(id: const Uuid().v4(), name: 'Player 1')],
        ),
      );
    });
  }

  void _removePlayer(int index) {
    ref.read(hapticServiceProvider).trigger(HapticType.selection);
    setState(() {
      _players.removeAt(index);
    });
  }

  void _removeTeam(int index) {
    ref.read(hapticServiceProvider).trigger(HapticType.selection);
    setState(() {
      _teams.removeAt(index);
    });
  }

  void _proceedToCategories() {
    // Check validation: Must have at least 2 teams or players
    if (_isTeamMode && _teams.length < 2) {
      // Auto-fill default Simba & Chui if user just wants to start fast
      setState(() {
        if (_teams.isEmpty) {
          _teams.add(const Team(
            id: 'team_1',
            name: 'Team Simba',
            colorHex: '#FFB800',
            players: [Player(id: 'p1', name: 'Player 1')],
          ));
          _teams.add(const Team(
            id: 'team_2',
            name: 'Team Chui',
            colorHex: '#00F0FF',
            players: [Player(id: 'p2', name: 'Player 2')],
          ));
        } else if (_teams.length == 1) {
          _teams.add(const Team(
            id: 'team_2',
            name: 'Team Chui',
            colorHex: '#00F0FF',
            players: [Player(id: 'p2', name: 'Player 2')],
          ));
        }
      });
    } else if (!_isTeamMode && _players.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least 2 players to start!'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    ref.read(hapticServiceProvider).trigger(HapticType.success);

    // 1. Update difficulty in global settings
    ref.read(settingsNotifierProvider.notifier).setDifficulty(_selectedDifficulty);
    final globalSettings = ref.read(settingsNotifierProvider).copyWith(
          difficulty: _selectedDifficulty,
        );

    // If we are heading to Kings Cup, start the Kings Cup session and route there!
    if (widget.targetRoute == '/kings-cup') {
      final isFamilyMode = ref.read(settingsNotifierProvider).familyFriendlyMode;
      ref.read(kingsCupControllerProvider.notifier).startNewGame(
        players: _players,
        isFamilyMode: isFamilyMode,
      );
      context.push('/kings-cup');
      return;
    }

    // If heading to Do or Drink
    if (widget.targetRoute != null && widget.targetRoute!.startsWith('/do-or-drink')) {
      final uri = Uri.parse(widget.targetRoute!);
      final mode = uri.queryParameters['mode'] ?? 'friendly';
      ref.read(doOrDrinkControllerProvider.notifier).startNewGame(
        players: _players,
        mode: mode,
      );
      context.push('/do-or-drink');
      return;
    }

    // 2. Prepare teams (for Charades)
    List<Team> finalTeams;
    if (_isTeamMode) {
      finalTeams = _teams;
    } else {
      finalTeams = _players
          .map((p) => Team(
                id: p.id,
                name: p.name,
                colorHex: '#FFB800',
                players: [p],
              ))
          .toList();
    }

    // 3. Initialize Game Session in GameController
    final gameController = ref.read(gameControllerProvider.notifier);
    gameController.startCustomGame(
      settings: globalSettings,
      teams: finalTeams,
    );

    // 4. Navigate to Category Selection or target route
    context.push(widget.targetRoute ?? '/category-select');
  }

  void _navigateBack() {
    ref.read(hapticServiceProvider).trigger(HapticType.selection);
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsNotifierProvider);
    final isDark = settings.isDarkMode;
    final bg = isDark ? const Color(0xFF0B0E17) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF151B28) : Colors.white;
    final textMain = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF232D42) : const Color(0xFFCBD5E1);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
              // 1. Top Navigation Bar with Back Button
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: textMain, size: 18),
                      onPressed: _navigateBack,
                      tooltip: 'Back to Games',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'GAME SETUP 👥',
                    style: AppTypography.h2.copyWith(
                      color: textMain,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // 2. Mode Switcher: TEAMS vs INDIVIDUAL PLAYERS
              if (widget.targetRoute != '/kings-cup' && !(widget.targetRoute?.startsWith('/do-or-drink') ?? false))
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isTeamMode = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: _isTeamMode ? AppColors.primaryGradient : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '🔥 TEAMS',
                              style: TextStyle(
                                color: _isTeamMode ? Colors.black : textSub,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isTeamMode = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: !_isTeamMode ? AppColors.primaryGradient : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '🙋🏾 INDIVIDUALS',
                              style: TextStyle(
                                color: !_isTeamMode ? Colors.black : textSub,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. Difficulty Selector (Easy / Medium / Hard / Mixed)
              if (widget.targetRoute != '/kings-cup' && !(widget.targetRoute?.startsWith('/do-or-drink') ?? false)) ...[
                Text(
                  'DIFFICULTY LEVEL',
                  style: TextStyle(
                    color: textSub,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      _buildDifficultyChip('all', '🎲 MIXED', cardBg, textSub),
                      _buildDifficultyChip('easy', '🟢 EASY', cardBg, textSub),
                      _buildDifficultyChip('medium', '🟡 MED', cardBg, textSub),
                      _buildDifficultyChip('hard', '🔴 HARD', cardBg, textSub),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 4. Input Field to Add Squad or Player
              Text(
                _isTeamMode ? 'ADD SQUADS / TEAMS' : 'ADD PLAYERS',
                style: TextStyle(
                  color: textSub,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(color: textMain, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: _isTeamMode ? 'Squad name (e.g. Simba, Hustlers)' : 'Player name',
                        hintStyle: TextStyle(color: textSub.withOpacity(0.7), fontSize: 13),
                        filled: true,
                        fillColor: cardBg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.savannaGold, width: 2),
                        ),
                      ),
                      onSubmitted: (_) => _addCustomEntry(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                      ),
                      onPressed: _addCustomEntry,
                      child: const Text(
                        '+ ADD',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),

              // 5. Quick Suggested Squad Chips (1-Tap Fast Addition)
              if (_isTeamMode) ...[
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _quickTeamSuggestions.map((s) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          backgroundColor: cardBg,
                          side: BorderSide(color: borderColor),
                          label: Text(
                            '+ ${s['name']} ${s['emoji']}',
                            style: TextStyle(color: textMain, fontWeight: FontWeight.w700, fontSize: 11),
                          ),
                          onPressed: () => _addSuggestedTeam(s['name']!, s['color']!),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // 6. Active List of Entered Teams/Players
              if (_isTeamMode) ...[
                if (_teams.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor.withOpacity(0.5)),
                    ),
                    child: Center(
                      child: Text(
                        'No squads added yet.\nType a name above or tap suggested squads!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textSub, fontSize: 13),
                      ),
                    ),
                  )
                else
                  ..._teams.asMap().entries.map((e) => _buildTeamTile(e.key, e.value, cardBg, textMain, textSub, borderColor)),
              ] else ...[
                if (_players.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor.withOpacity(0.5)),
                    ),
                    child: Center(
                      child: Text(
                        'No players added yet.\nType player names above to join!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textSub, fontSize: 13),
                      ),
                    ),
                  )
                else
                  ..._players.asMap().entries.map((e) => _buildPlayerTile(e.key, e.value, cardBg, textMain, textSub, borderColor)),
              ],

              const SizedBox(height: 24),

              // 7. Single Obvious Action Button: CONTINUE TO CATEGORIES →
              ChezaButton(
                text: 'CONTINUE TO CATEGORIES →',
                variant: ChezaButtonVariant.primary,
                onPressed: _proceedToCategories,
              ),

              const SizedBox(height: 20),
            ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(String diff, String label, Color cardBg, Color textSub) {
    final isSelected = _selectedDifficulty == diff;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(hapticServiceProvider).trigger(HapticType.selection);
          setState(() => _selectedDifficulty = diff);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : textSub,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamTile(int i, Team team, Color cardBg, Color textMain, Color textSub, Color borderColor) {
    Color teamColor = AppColors.savannaGold;
    try {
      teamColor = Color(int.parse(team.colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: teamColor.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: teamColor.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: teamColor),
            ),
            child: Center(
              child: Text(
                i == 0 ? '🦁' : (i == 1 ? '🐆' : (i == 2 ? '🌿' : '⚡')),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  style: TextStyle(
                    color: textMain,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Squad ${i + 1}',
                  style: TextStyle(color: textSub, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 20),
            onPressed: () => _removeTeam(i),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerTile(int i, Player player, Color cardBg, Color textMain, Color textSub, Color borderColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.savannaGold.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                player.avatar ?? '🙋🏾‍♂️',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              player.name,
              style: TextStyle(
                color: textMain,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 20),
            onPressed: () => _removePlayer(i),
          ),
        ],
      ),
    );
  }
}
