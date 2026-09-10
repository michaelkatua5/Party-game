import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/game_settings.dart';
import '../../../domain/models/player.dart';
import '../../../domain/models/team.dart';
import '../../../shared/widgets/kenyan_button.dart';
import '../../categories/providers/category_providers.dart';
import '../../game/providers/game_controller.dart';
import '../../settings/providers/settings_provider.dart';

class CustomGameScreen extends ConsumerStatefulWidget {
  const CustomGameScreen({super.key});

  @override
  ConsumerState<CustomGameScreen> createState() => _CustomGameScreenState();
}

class _CustomGameScreenState extends ConsumerState<CustomGameScreen> {
  int _roundDuration = 60;
  int _totalRounds = 3;
  String _difficulty = 'all';
  final List<String> _selectedCategoryIds = [];
  final bool _allowPassing = true;
  int _passPenalty = 0;
  bool _drinkingMode = false;
  bool _familyFriendly = true;

  final List<TextEditingController> _teamControllers = [
    TextEditingController(text: 'Team Simba'),
    TextEditingController(text: 'Team Chui'),
  ];

  @override
  void initState() {
    super.initState();
    final currentSettings = ref.read(settingsNotifierProvider);
    _roundDuration = currentSettings.roundDurationSeconds;
    _totalRounds = currentSettings.totalRounds;
    _difficulty = currentSettings.difficulty;
    _drinkingMode = currentSettings.drinkingMode;
    _familyFriendly = currentSettings.familyFriendlyMode;
  }

  @override
  void dispose() {
    for (var c in _teamControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addTeam() {
    if (_teamControllers.length < 4) {
      final nextIndex = _teamControllers.length;
      final defaultName = nextIndex < AppDefaults.defaultTeamNames.length
          ? AppDefaults.defaultTeamNames[nextIndex]
          : 'Team ${nextIndex + 1}';
      setState(() {
        _teamControllers.add(TextEditingController(text: defaultName));
      });
    }
  }

  void _removeTeam(int index) {
    if (_teamControllers.length > 2) {
      setState(() {
        _teamControllers.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categoriesAsync = ref.watch(categoriesFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('custom_game')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Teams Configuration
            _buildSectionHeader('👥 TEAMS & SQUADS', 'Configure 2 to 4 competing teams'),
            const SizedBox(height: 12),
            ...List.generate(_teamControllers.length, (index) {
              final colorHex = AppDefaults.defaultTeamColors[index % AppDefaults.defaultTeamColors.length];
              final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: color,
                      radius: 16,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _teamControllers[index],
                        decoration: InputDecoration(
                          hintText: 'Team ${index + 1} Name',
                          prefixIcon: const Icon(Icons.shield_outlined, color: Colors.white70),
                        ),
                      ),
                    ),
                    if (_teamControllers.length > 2) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.danger),
                        onPressed: () => _removeTeam(index),
                      ),
                    ],
                  ],
                ),
              );
            }),

            if (_teamControllers.length < 4)
              TextButton.icon(
                onPressed: _addTeam,
                icon: const Icon(Icons.add, color: AppColors.savannaGold),
                label: const Text(
                  '+ Add Another Team',
                  style: TextStyle(color: AppColors.savannaGold, fontWeight: FontWeight.bold),
                ),
              ),

            const SizedBox(height: 24),

            // Section 2: Round Timer & Duration
            _buildSectionHeader('⏱️ ROUND TIMER', 'How long each player has to act'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [30, 45, 60, 90, 120].map((sec) {
                final isSelected = _roundDuration == sec;
                return ChoiceChip(
                  label: Text('${sec}s'),
                  selected: isSelected,
                  selectedColor: AppColors.sunsetOrange,
                  backgroundColor: AppColors.darkCard,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textMuted,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (_) => setState(() => _roundDuration = sec),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Section 3: Number of Rounds
            _buildSectionHeader('🔄 TOTAL ROUNDS', 'Number of complete turns for each team'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [1, 2, 3, 5, 10].map((r) {
                final isSelected = _totalRounds == r;
                return ChoiceChip(
                  label: Text('$r Rounds'),
                  selected: isSelected,
                  selectedColor: AppColors.savannaGold,
                  backgroundColor: AppColors.darkCard,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.darkBackground : AppColors.textMuted,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (_) => setState(() => _totalRounds = r),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Section 4: Difficulty Level
            _buildSectionHeader('🔥 DIFFICULTY', 'Filter word card challenge level'),
            const SizedBox(height: 12),
            Row(
              children: ['all', 'easy', 'medium', 'hard'].map((diff) {
                final isSelected = _difficulty == diff;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(diff.toUpperCase()),
                    selected: isSelected,
                    selectedColor: AppColors.riftCyan,
                    backgroundColor: AppColors.darkCard,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) => setState(() => _difficulty = diff),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Section 5: Categories Selection
            _buildSectionHeader('📚 SELECT CATEGORIES', 'Leave empty to play all categories'),
            const SizedBox(height: 12),
            categoriesAsync.when(
              data: (categories) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  final isSelected = _selectedCategoryIds.contains(cat.id);
                  return FilterChip(
                    label: Text(cat.name),
                    selected: isSelected,
                    selectedColor: AppColors.forestEmerald.withOpacity(0.3),
                    checkmarkColor: AppColors.forestEmerald,
                    backgroundColor: AppColors.darkCard,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.forestEmerald : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategoryIds.add(cat.id);
                        } else {
                          _selectedCategoryIds.remove(cat.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Failed to load categories', style: TextStyle(color: Colors.white)),
            ),

            const SizedBox(height: 24),

            // Section 6: Party & Drinking Mode Toggle
            _buildSectionHeader('🎉 PARTY & DRINKING RULES', 'Optional party rules & penalties'),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pass Penalty (Deduct 1 Pt)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Minus 1 point whenever a team chooses to pass', style: TextStyle(color: AppColors.textMuted)),
              value: _passPenalty == -1,
              onChanged: (val) => setState(() => _passPenalty = val ? -1 : 0),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Party / Drinking Mode 🍻', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Includes funny sips/shots penalties on passes and forfeits', style: TextStyle(color: AppColors.textMuted)),
              value: _drinkingMode,
              onChanged: (val) {
                setState(() {
                  _drinkingMode = val;
                  if (val) _familyFriendly = false;
                });
              },
            ),

            if (_drinkingMode)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.purpleSherehe.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(color: AppColors.hotPink.withOpacity(0.5)),
                ),
                child: const Text(
                  '⚠️ Party Reminder: Please drink responsibly. Water or juice can also be used for sips!',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),

            const SizedBox(height: 36),

            // Launch Button
            KenyanButton(
              text: '🚀 START CUSTOM GAME',
              gradient: AppColors.primaryGradient,
              height: 60,
              onPressed: () async {
                final teams = _teamControllers.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final name = entry.value.text.trim().isNotEmpty
                      ? entry.value.text.trim()
                      : 'Team ${idx + 1}';
                  final colorHex = AppDefaults.defaultTeamColors[idx % AppDefaults.defaultTeamColors.length];

                  return Team(
                    id: 'team_${idx + 1}',
                    name: name,
                    colorHex: colorHex,
                    players: [
                      Player(id: 'p_${idx}_1', name: '$name Player 1'),
                      Player(id: 'p_${idx}_2', name: '$name Player 2'),
                    ],
                  );
                }).toList();

                final settings = GameSettings(
                  roundDurationSeconds: _roundDuration,
                  totalRounds: _totalRounds,
                  difficulty: _difficulty,
                  selectedCategoryIds: _selectedCategoryIds,
                  allowPassing: _allowPassing,
                  passPenalty: _passPenalty,
                  drinkingMode: _drinkingMode,
                  familyFriendlyMode: _familyFriendly,
                );

                await ref.read(gameControllerProvider.notifier).startCustomGame(
                      settings: settings,
                      teams: teams,
                    );

                if (context.mounted) {
                  context.push('/game');
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.savannaGold,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      ],
    );
  }
}
