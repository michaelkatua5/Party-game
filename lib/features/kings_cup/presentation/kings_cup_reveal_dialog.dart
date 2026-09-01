import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/models/kings_card.dart';
import '../../../domain/models/player.dart';
import '../providers/kings_cup_controller.dart';
import 'kings_cup_king_rule_dialog.dart';

class KingsCupRevealDialog extends ConsumerStatefulWidget {
  final KingsCard card;
  final bool isFamilyMode;
  final List<Player> players;
  final Player currentPlayer;
  final VoidCallback onNext;

  const KingsCupRevealDialog({
    super.key,
    required this.card,
    required this.isFamilyMode,
    required this.players,
    required this.currentPlayer,
    required this.onNext,
  });

  @override
  ConsumerState<KingsCupRevealDialog> createState() => _KingsCupRevealDialogState();
}

class _KingsCupRevealDialogState extends ConsumerState<KingsCupRevealDialog> {
  String? _selectedPlayerName;
  int _countdownTimer = 3;
  bool _countdownActive = false;
  Timer? _timer;

  static const List<String> _neverHaveIEverPrompts = [
    'Never have I ever boarded the wrong Matatu in Nairobi.',
    'Never have I ever lied about being "almost there" when I was still at home.',
    'Never have I ever eaten Mutura at 1:00 AM.',
    'Never have I ever pretended to be on a phone call to avoid someone.',
    'Never have I ever lost my phone in a club.',
    'Never have I ever eaten someone else\'s food in the office or hostel fridge.',
  ];

  static const List<String> _categoryPrompts = [
    'Kenyan Slang / Sheng Words',
    'Nairobi Matatu Stages',
    'Kenyan Musicians & Artists',
    'Local Kenyan Delicacies & Street Foods',
    'Kenyan Football Teams / Athletes',
    'Kenyan TV Shows & Comedians',
  ];

  static const List<String> _rhymePrompts = [
    'Manze (Panze, Sanze...)',
    'Kula (Lala, Chapa...)',
    'Sherehe (Mbebe, Mele...)',
    'Bazu (Vazu, Chazu...)',
    'Ngoma (Soma, Toma...)',
  ];

  void _startMiniCountdown() {
    setState(() {
      _countdownActive = true;
      _countdownTimer = 3;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdownTimer > 1) {
        setState(() => _countdownTimer--);
      } else {
        _timer?.cancel();
        setState(() => _countdownActive = false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final suitColor = card.isRed ? const Color(0xFFDC2626) : const Color(0xFF0F172A);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 640),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB), // Vintage playing card ivory
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Card Top Index (e.g. 5 ♥)
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  '${card.rankDisplay} ${card.suitSymbol}',
                  style: TextStyle(
                    color: suitColor,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Big Rule Title (e.g. "GUYS", "WATERFALL", "YOU")
              Text(
                card.ruleTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: suitColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 10),

              // Icon / Illustration
              Text(
                card.iconEmoji,
                style: const TextStyle(fontSize: 48),
              ),

              const SizedBox(height: 12),

              // Rule Action Explanation
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  widget.isFamilyMode ? card.familyRuleDescription : card.ruleDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 🎯 Interactive Rule Handlers
              _buildRuleInteraction(card),

              const SizedBox(height: 20),

              // "DONE" / "NEXT PLAYER" Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: widget.onNext,
                  child: const Text(
                    'DONE & NEXT PLAYER',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleInteraction(KingsCard card) {
    // 1. "YOU" (Rank 2) -> Player selection
    if (card.rank == CardRank.two) {
      final otherPlayers = widget.players.where((p) => p.id != widget.currentPlayer.id).toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CHOOSE WHO TAKES THE PENALTY:',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: otherPlayers.map((p) {
              final isSelected = _selectedPlayerName == p.name;
              return ChoiceChip(
                label: Text('${p.avatar ?? '🧑🏾'} ${p.name}'),
                selected: isSelected,
                selectedColor: const Color(0xFF8B5CF6),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (_) {
                  setState(() => _selectedPlayerName = p.name);
                },
              );
            }).toList(),
          ),
        ],
      );
    }

    // 2. "MATE" (Rank 8) -> Partner selection
    if (card.rank == CardRank.eight) {
      final otherPlayers = widget.players.where((p) => p.id != widget.currentPlayer.id).toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CHOOSE YOUR DRINKING MATE:',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: otherPlayers.map((p) {
              final isSelected = _selectedPlayerName == p.name;
              return ChoiceChip(
                label: Text('🤝 ${p.name}'),
                selected: isSelected,
                selectedColor: AppColors.savannaGold,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.textDark : const Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (_) {
                  setState(() => _selectedPlayerName = p.name);
                  ref.read(kingsCupControllerProvider.notifier).linkMate(
                        playerAId: widget.currentPlayer.id,
                        playerBId: p.id,
                      );
                },
              );
            }).toList(),
          ),
        ],
      );
    }

    // 3. "FLOOR" (Rank 4) & "HEAVEN" (Rank 7) -> Buzzer countdown
    if (card.rank == CardRank.four || card.rank == CardRank.seven) {
      return Column(
        children: [
          if (_countdownActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$_countdownTimer',
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
              ),
            )
          else
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.timer, size: 18),
              label: Text('START ${card.ruleTitle} BUZZER!'),
              onPressed: _startMiniCountdown,
            ),
        ],
      );
    }

    // 4. "NEVER HAVE I EVER" (Jack) -> Curated Prompt
    if (card.rank == CardRank.jack) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💡 SUGGESTED PROMPT:',
              style: TextStyle(color: Color(0xFF475569), fontSize: 10, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              _neverHaveIEverPrompts[DateTime.now().second % _neverHaveIEverPrompts.length],
              style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // 5. "CATEGORIES" (Rank 10) -> Curated Category
    if (card.rank == CardRank.ten) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💡 SUGGESTED CATEGORY:',
              style: TextStyle(color: Color(0xFF475569), fontSize: 10, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              _categoryPrompts[DateTime.now().second % _categoryPrompts.length],
              style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // 6. "RHYME" (Rank 9) -> Starting Rhyme Word
    if (card.rank == CardRank.nine) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💡 SUGGESTED START WORD:',
              style: TextStyle(color: Color(0xFF475569), fontSize: 10, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              _rhymePrompts[DateTime.now().second % _rhymePrompts.length],
              style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
