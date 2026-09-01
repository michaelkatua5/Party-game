import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../domain/models/kings_card.dart';
import '../providers/kings_cup_controller.dart';
import 'kings_cup_reveal_dialog.dart';
import 'kings_cup_king_rule_dialog.dart';

class KingsCupBoardScreen extends ConsumerWidget {
  const KingsCupBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(kingsCupControllerProvider);
    final notifier = ref.read(kingsCupControllerProvider.notifier);

    if (session == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0B1E),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No active Kings Cup session', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  notifier.startNewGame();
                },
                child: const Text('Start Kings Cup'),
              ),
            ],
          ),
        ),
      );
    }

    final currentPlayer = session.currentPlayer;
    final kingsDrawn = session.kingsDrawnCount;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0B1E),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => context.go('/home'),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('👑', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(
              'KINGS CUP',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL, vertical: 12),
          child: Column(
            children: [
              // Top Stats Row: CARDS REMAINING & KINGS COUNTER matching Blueprint Screen 11 & 14
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CARDS REMAINING',
                        style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${session.cardsRemaining}',
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),

                  // Kings Counter e.g. 2/4 with crowns
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'KINGS',
                        style: TextStyle(color: AppColors.savannaGold, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$kingsDrawn / 4',
                        style: const TextStyle(color: AppColors.savannaGold, fontSize: 26, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: List.generate(4, (index) {
                          final isDrawn = index < kingsDrawn;
                          return Padding(
                            padding: const EdgeInsets.only(left: 3),
                            child: Text(
                              isDrawn ? '👑' : '⚪',
                              style: TextStyle(fontSize: isDrawn ? 16 : 10),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(flex: 1),

              // Royal Deck Center Stack with 3D layers
              GestureDetector(
                onTap: () => _handleDrawCard(context, ref),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Layer 3 (Background depth)
                    Container(
                      width: 170,
                      height: 230,
                      transform: Matrix4.translationValues(8, 8, 0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1736),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF3B2F63)),
                      ),
                    ),
                    // Layer 2 (Middle depth)
                    Container(
                      width: 170,
                      height: 230,
                      transform: Matrix4.translationValues(4, 4, 0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF261947),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF4C3682)),
                      ),
                    ),
                    // Top Deck Card
                    Container(
                      width: 170,
                      height: 230,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B1E78),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.savannaGold, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('👑', style: TextStyle(fontSize: 48)),
                          SizedBox(height: 8),
                          Text(
                            'TAP TO\nDRAW',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // CURRENT PLAYER Indicator
              Column(
                children: [
                  const Text(
                    'CURRENT PLAYER',
                    style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentPlayer.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // DRAW CARD Button matching Blueprint
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.savannaGold,
                    foregroundColor: AppColors.textDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => _handleDrawCard(context, ref),
                  child: const Text(
                    'DRAW CARD',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ACTIVE RULES Section with dynamic deletion
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1530),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF2E2452)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ACTIVE RULES',
                          style: TextStyle(
                            color: AppColors.savannaGold,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        if (session.activeRules.isNotEmpty)
                          Text(
                            '${session.activeRules.length} Active',
                            style: const TextStyle(color: Colors.white38, fontSize: 10),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (session.activeRules.isEmpty)
                      const Text(
                        'No custom rules active yet. Draw a King to make a rule!',
                        style: TextStyle(color: Colors.white38, fontSize: 12, fontStyle: FontStyle.italic),
                      )
                    else
                      ...List.generate(session.activeRules.length, (i) {
                        final rule = session.activeRules[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Text('⚠️', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  rule,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(4),
                                icon: const Icon(Icons.close, color: Colors.white38, size: 16),
                                onPressed: () {
                                  notifier.removeCustomRule(i);
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _handleDrawCard(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(kingsCupControllerProvider.notifier);
    final card = notifier.drawCard();
    if (card == null) return;

    final session = ref.read(kingsCupControllerProvider);
    if (session == null) return;

    // If 4th King drawn -> Transition to Final King Finale Screen
    if (session.isGameOver) {
      context.push('/kings-cup/final-king');
      return;
    }

    // If King drawn -> Open Card Reveal then Rule Creator
    if (card.isKing) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => KingsCupRevealDialog(
          card: card,
          isFamilyMode: session.isFamilyMode,
          players: session.players,
          currentPlayer: session.currentPlayer,
          onNext: () {
            Navigator.of(context).pop();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => KingsCupKingRuleDialog(
                onRuleAdded: (rule) {
                  notifier.addCustomRule(rule);
                  notifier.nextPlayer();
                },
              ),
            );
          },
        ),
      );
    } else {
      // Normal interactive card reveal dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => KingsCupRevealDialog(
          card: card,
          isFamilyMode: session.isFamilyMode,
          players: session.players,
          currentPlayer: session.currentPlayer,
          onNext: () {
            Navigator.of(context).pop();
            notifier.nextPlayer();
          },
        ),
      );
    }
  }
}
