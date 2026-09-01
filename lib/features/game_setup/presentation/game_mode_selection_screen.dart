import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../game/providers/game_controller.dart';
import '../../kings_cup/providers/kings_cup_controller.dart';

class GameModeSelectionScreen extends ConsumerWidget {
  const GameModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0B1E),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'WHAT ARE WE\nPLAYING?',
                textAlign: TextAlign.center,
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pick a party game to kick off the night',
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),

              const SizedBox(height: 36),

              // 1. CHARADES CARD (Purple)
              GestureDetector(
                onTap: () => context.push('/player-setup'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF261947),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🎭', style: TextStyle(fontSize: 40)),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'CHARADES',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Act it. Guess it.\nTilt to answer.',
                              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.2),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: Color(0xFF8B5CF6), size: 28),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 2. KINGS CUP CARD (Gold)
              GestureDetector(
                onTap: () {
                  ref.read(kingsCupControllerProvider.notifier).startNewGame();
                  context.push('/kings-cup');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF332308),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.savannaGold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.savannaGold.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.savannaGold.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('👑', style: TextStyle(fontSize: 40)),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'KINGS CUP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Draw a card.\nFollow the rule.\nSurvive the night.',
                              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.2),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: AppColors.savannaGold, size: 28),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
