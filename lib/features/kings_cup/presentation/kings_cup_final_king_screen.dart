import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/confetti_overlay.dart';
import '../providers/kings_cup_controller.dart';

class KingsCupFinalKingScreen extends ConsumerWidget {
  const KingsCupFinalKingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(kingsCupControllerProvider);
    final drawerName = session?.currentPlayer.name ?? 'The Player';

    return ConfettiOverlay(
      isPlaying: true,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0B1E),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),

                // Title: THE FINAL KING!
                Text(
                  '👑 THE FINAL KING! 👑',
                  style: TextStyle(
                    color: AppColors.savannaGold,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ).animate().fadeIn().scale(duration: 400.ms),

                const SizedBox(height: 28),

                // Giant Glowing Crown Illustration
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.savannaGold.withOpacity(0.15),
                    border: Border.all(color: AppColors.savannaGold, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.savannaGold.withOpacity(0.4),
                        blurRadius: 40,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Text('👑', style: TextStyle(fontSize: 72)),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                const SizedBox(height: 28),

                // Drawer Callout
                Text(
                  drawerName.toUpperCase(),
                  style: AppTypography.gameTitle.copyWith(
                    fontSize: 32,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'drew the 4th and Final King!',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),

                const SizedBox(height: 20),

                // Penalty Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1736),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF3B2F63)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'FINAL FORFEIT / PENALTY',
                        style: TextStyle(
                          color: AppColors.savannaGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        session?.isFamilyMode == true
                          ? '🎉 Complete the ultimate party dare: Sing a Kenyan song chorus while standing on one foot! 🕺'
                          : '🍻 Take the center King\'s Cup sip, or choose a safe forfeit decided by the group! 🔥',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // PLAY AGAIN Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.savannaGold,
                      foregroundColor: AppColors.textDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      ref.read(kingsCupControllerProvider.notifier).startNewGame();
                      context.go('/kings-cup');
                    },
                    child: const Text(
                      'PLAY AGAIN 👑',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // RETURN HOME Button
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: const Text(
                    'Return to Home',
                    style: TextStyle(color: Colors.white60, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
