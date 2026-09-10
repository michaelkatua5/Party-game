import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../domain/models/kings_cup_session.dart';
import '../providers/kings_cup_controller.dart';
import 'kings_cup_reveal_dialog.dart';

class KingsCupBoardScreen extends ConsumerWidget {
  const KingsCupBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(kingsCupControllerProvider);
    final notifier = ref.read(kingsCupControllerProvider.notifier);

    ref.listen<KingsCupSession?>(kingsCupControllerProvider, (prev, next) {
      if (next?.isGameOver == true) {
        context.go('/kings-cup/final-king');
      }
    });

    if (session == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0B1A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Kings Cup session not started', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.savannaGold,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('GO BACK', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final activeRules = session.activeRules;
    final kingsDrawn = session.kingsDrawnCount;

    Future<void> onDrawCard() async {
      final card = notifier.drawCard();
      if (card != null) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => KingsCupRevealDialog(
            card: card,
            isFamilyMode: session.isFamilyMode,
            players: session.players,
            currentPlayer: session.currentPlayer,
            onNext: () {
              Navigator.of(ctx).pop();
              notifier.nextPlayer();
            },
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B1A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          'KINGS CUP 👑',
          style: AppTypography.h2.copyWith(
            color: AppColors.savannaGold,
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white54, size: 22),
            tooltip: 'Reset Deck',
            onPressed: () => notifier.startNewGame(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background — dark purple with suit symbols pattern
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _CardSuitPatternPainter(),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),

                // ── Stats bar ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.savannaGold.withOpacity(0.35), width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            const Text('👑', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              '$kingsDrawn / 4 Kings',
                              style: const TextStyle(
                                color: AppColors.savannaGold,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          color: AppColors.savannaGold.withOpacity(0.3),
                        ),
                        Row(
                          children: [
                            const Text('🃏', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              '${session.cardsRemaining} Cards Left',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Active rules shelf ─────────────────────────────────────
                if (activeRules.isNotEmpty)
                  Container(
                    height: 44,
                    margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: activeRules.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (ctx, i) {
                        final rule = activeRules[i];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.partyPurple.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.partyPurple.withOpacity(0.4)),
                          ),
                          child: Row(
                            children: [
                              const Text('📜 ', style: TextStyle(fontSize: 11)),
                              Text(rule, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => notifier.removeActiveRule(rule),
                                child: const Icon(Icons.close, color: Colors.white54, size: 13),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                const Spacer(),

                // ── Ornate card ────────────────────────────────────────────
                GestureDetector(
                  onTap: onDrawCard,
                  child: _OrnateKingsCupCard(),
                ),

                const SizedBox(height: 32),

                // ── Player turn callout ────────────────────────────────────
                Text(
                  '✦  ${session.currentTurnPlayerName}, your turn to Cheza!  ✦',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.savannaGold,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: AppColors.savannaGold.withOpacity(0.4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(duration: 600.ms)
                  .then()
                  .custom(
                    duration: 1800.ms,
                    curve: Curves.easeInOut,
                    builder: (ctx, value, child) => Opacity(opacity: 0.65 + 0.35 * value, child: child),
                  ),

                const Spacer(),

                // ── Draw button ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: GestureDetector(
                    onTap: onDrawCard,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.savannaGold,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.savannaGold.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.back_hand_outlined, color: Colors.black, size: 22),
                          SizedBox(width: 10),
                          Text(
                            'DRAW CARD  🃏',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ornate KC card widget
// ─────────────────────────────────────────────────────────────────────────────
class _OrnateKingsCupCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 340,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1433),
            Color(0xFF0D0B1A),
            Color(0xFF1A1433),
          ],
        ),
        border: Border.all(color: AppColors.savannaGold, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.savannaGold.withOpacity(0.55),
            blurRadius: 40,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: AppColors.savannaGold.withOpacity(0.2),
            blurRadius: 80,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative diamond grid pattern
            Positioned.fill(
              child: CustomPaint(painter: _CardPatternPainter()),
            ),

            // Inner gold border
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.savannaGold.withOpacity(0.6), width: 1.5),
                ),
              ),
            ),

            // Corner suit symbols
            _buildCornerSuit(Alignment.topLeft, '♠'),
            _buildCornerSuit(Alignment.topRight, '♥'),
            _buildCornerSuit(Alignment.bottomLeft, '♦'),
            _buildCornerSuit(Alignment.bottomRight, '♣'),

            // Center crest
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Crown
                  Text(
                    '♛',
                    style: TextStyle(
                      color: AppColors.savannaGold,
                      fontSize: 38,
                      shadows: [
                        Shadow(color: AppColors.savannaGold.withOpacity(0.8), blurRadius: 16),
                      ],
                    ),
                  )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(end: 1.06, duration: 1400.ms, curve: Curves.easeInOut),
                  const SizedBox(height: 6),
                  // KC shield
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.savannaGold, width: 2),
                      gradient: RadialGradient(
                        colors: [
                          AppColors.savannaGold.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.savannaGold.withOpacity(0.3),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'K',
                              style: TextStyle(
                                color: AppColors.savannaGold,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -2,
                                shadows: [Shadow(color: AppColors.savannaGold, blurRadius: 8)],
                              ),
                            ),
                            TextSpan(
                              text: 'C',
                              style: TextStyle(
                                color: AppColors.savannaGold,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                shadows: [Shadow(color: AppColors.savannaGold, blurRadius: 8)],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Decorative divider
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 30, height: 1, color: AppColors.savannaGold.withOpacity(0.6)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text('♦', style: TextStyle(color: AppColors.savannaGold.withOpacity(0.8), fontSize: 10)),
                      ),
                      Container(width: 30, height: 1, color: AppColors.savannaGold.withOpacity(0.6)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
      .animate(onPlay: (c) => c.repeat(reverse: true))
      .custom(
        duration: 2000.ms,
        curve: Curves.easeInOut,
        builder: (ctx, value, child) {
          // Breathing glow intensity
          return child;
        },
      );
  }

  Widget _buildCornerSuit(Alignment alignment, String suit) {
    final isRed = suit == '♥' || suit == '♦';
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            suit,
            style: TextStyle(
              color: isRed
                  ? AppColors.savannaGold.withOpacity(0.5)
                  : AppColors.savannaGold.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background pattern painter — lightweight diamond grid (no TextPainter)
// ─────────────────────────────────────────────────────────────────────────────
class _CardSuitPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF16103A), Color(0xFF0D0B1A)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Subtle diamond grid
    final paint = Paint()
      ..color = const Color(0x0FC8A951)
      ..style = PaintingStyle.fill;

    const spacing = 48.0;
    const half = spacing / 4;
    final gridPath = Path();

    for (double y = 0; y < size.height + spacing; y += spacing) {
      for (double x = 0; x < size.width + spacing; x += spacing) {
        final cx = x + (((y / spacing).floor() % 2) == 0 ? 0 : spacing / 2);
        gridPath.moveTo(cx, y - half);
        gridPath.lineTo(cx + half, y);
        gridPath.lineTo(cx, y + half);
        gridPath.lineTo(cx - half, y);
        gridPath.close();
      }
    }
    canvas.drawPath(gridPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Card ornate diamond pattern painter
// ─────────────────────────────────────────────────────────────────────────────
class _CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.savannaGold.withOpacity(0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const step = 22.0;
    final gridPath = Path();
    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        const half = step / 2;
        gridPath.moveTo(x + half, y);
        gridPath.lineTo(x + step, y + half);
        gridPath.lineTo(x + half, y + step);
        gridPath.lineTo(x, y + half);
        gridPath.close();
      }
    }
    canvas.drawPath(gridPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
