import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/cheza_button.dart';
import '../../../domain/models/player.dart';
import '../domain/models/do_or_drink_session.dart';
import '../providers/do_or_drink_provider.dart';

class DoOrDrinkBoardScreen extends ConsumerStatefulWidget {
  const DoOrDrinkBoardScreen({super.key});

  @override
  ConsumerState<DoOrDrinkBoardScreen> createState() => _DoOrDrinkBoardScreenState();
}

class _DoOrDrinkBoardScreenState extends ConsumerState<DoOrDrinkBoardScreen> {
  bool _isCardRevealed = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(doOrDrinkControllerProvider);
    final notifier = ref.read(doOrDrinkControllerProvider.notifier);

    if (session == null) {
      return Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(
          child: ChezaButton(
            text: 'GO BACK',
            isFullWidth: false,
            onPressed: () => context.pop(),
          ),
        ),
      );
    }

    Color themeColor;
    Color secondaryNeon;
    if (session.mode == 'spicy') {
      themeColor = const Color(0xFFFF2A6D); // Hot pink/red
      secondaryNeon = const Color(0xFF05D9E8); // Cyan
    } else if (session.mode == 'mild') {
      themeColor = AppColors.savannaGold; // Yellow/Gold
      secondaryNeon = const Color(0xFFFF2A6D); // Hot Pink
    } else {
      themeColor = const Color(0xFF38BDF8); // Friendly Blue
      secondaryNeon = const Color(0xFFD926A9); // Magenta
    }

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
      body: Stack(
        children: [
          // Background Glow
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.9,
                colors: [
                  themeColor.withOpacity(0.25), // Center glow based on mode
                  const Color(0xFF101018), // Dark edge
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
          
          // Subtle Tech Grid
          Positioned.fill(
            child: CustomPaint(
              painter: _TechPatternPainter(themeColor),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(),

                // The Card
                Center(
                child: GestureDetector(
                  onTap: () {
                    if (!_isCardRevealed) {
                      notifier.drawCard();
                      setState(() {
                        _isCardRevealed = true;
                      });
                    } else {
                      setState(() {
                        _isCardRevealed = false;
                      });
                      Future.delayed(const Duration(milliseconds: 400), () {
                        notifier.nextTurn();
                      });
                    }
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      final rotateAnim = Tween(begin: 3.14, end: 0.0).animate(animation);
                      return AnimatedBuilder(
                        animation: rotateAnim,
                        child: child,
                        builder: (context, widget) {
                          final isUnder = (ValueKey(_isCardRevealed) != widget?.key);
                          var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
                          tilt *= isUnder ? -1.0 : 1.0;
                          final value = isUnder ? min(rotateAnim.value, 3.14 / 2) : rotateAnim.value;
                          return Transform(
                            transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
                            alignment: Alignment.center,
                            child: widget,
                          );
                        },
                      );
                    },
                    child: _isCardRevealed
                        ? _buildRevealedCard(themeColor, secondaryNeon, session.currentPrompt ?? '')
                        : _buildDeckCardBack(themeColor, secondaryNeon),
                  ),
                ),
              ),

              const Spacer(),
              
              // Sleek Bottom Player Dock
              _buildPlayerDock(session, themeColor),
              const SizedBox(height: 16),
            ],
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildPlayerDock(DoOrDrinkSession session, Color themeColor) {
    return Container(
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF13151D),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white12, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: session.players.asMap().entries.map((entry) {
          final index = entry.key;
          final player = entry.value;
          final isActive = index == session.currentPlayerIndex;
          return _buildDockPlayer(player, isActive, themeColor);
        }).toList(),
      ),
    );
  }

  Widget _buildDockPlayer(Player player, bool isActive, Color themeColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isActive ? 52 : 44,
          height: isActive ? 52 : 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1A1C26),
            border: Border.all(
              color: isActive ? themeColor : Colors.white24,
              width: isActive ? 2.5 : 1.0,
            ),
            boxShadow: isActive ? [
              BoxShadow(color: themeColor.withOpacity(0.4), blurRadius: 12, spreadRadius: 2)
            ] : null,
          ),
          child: Center(
            child: Text(
              (player.avatar ?? '').isNotEmpty ? player.avatar! : '🙋',
              style: TextStyle(fontSize: isActive ? 24 : 18),
            ),
          ),
        ),
        const SizedBox(height: 4),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            color: isActive ? themeColor : Colors.white54,
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
          ),
          child: Text(player.name.toUpperCase()),
        ),
      ],
    );
  }

  Widget _buildDeckCardBack(Color themeColor, Color secondaryNeon) {
    return _buildNeonCardWrapper(
      themeColor: themeColor,
      secondaryNeon: secondaryNeon,
      isRevealed: false,
      child: Stack(
        children: [
          // Infinite Icon Top Right
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF161822),
                borderRadius: BorderRadius.circular(8), // More like a cut corner tag
                border: Border.all(color: Colors.white12, width: 1.5),
              ),
              child: const Text(
                '∞ / ∞',
                style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.0),
              ),
            ),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMetallicCoin(themeColor)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(end: 1.03, duration: 1500.ms, curve: Curves.easeInOut),
                const SizedBox(height: 52),
                _buildTapToDrawButton(themeColor, secondaryNeon),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevealedCard(Color themeColor, Color secondaryNeon, String prompt) {
    return _buildNeonCardWrapper(
      themeColor: themeColor,
      secondaryNeon: secondaryNeon,
      isRevealed: true,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [themeColor.withOpacity(0.2), secondaryNeon.withOpacity(0.2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: themeColor.withOpacity(0.6)),
              ),
              child: Text(
                'DO OR DRINK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 2.0,
                  shadows: [Shadow(color: themeColor, blurRadius: 8)],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              prompt,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.3,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeonCardWrapper({required Widget child, required Color themeColor, required Color secondaryNeon, required bool isRevealed}) {
    return Container(
      key: ValueKey(isRevealed),
      width: 290,
      height: 420,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeColor.withOpacity(0.9),
            secondaryNeon.withOpacity(0.6),
            themeColor.withOpacity(0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.4),
            blurRadius: 35,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: secondaryNeon.withOpacity(0.2),
            blurRadius: 40,
            spreadRadius: -5,
            offset: const Offset(10, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(3.5),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.5),
            // Premium leather/carbon textured gradient effect
            gradient: const RadialGradient(
              center: Alignment(-0.5, -0.6),
              radius: 1.5,
              colors: [
                Color(0xFF2C3140),
                Color(0xFF13151D),
                Color(0xFF0A0C11),
              ],
              stops: [0.0, 0.6, 1.0],
            ),
            border: Border.all(color: Colors.white12, width: 1.0), // Inner metallic rim
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildMetallicCoin(Color themeColor) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Chrome/Metallic effect
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.1, 0.3, 0.5, 0.7, 0.9],
          colors: [
            Color(0xFFFFFFFF), // Highlight
            Color(0xFF8892A0), // Mid
            Color(0xFFD1D5DB), // Reflected light
            Color(0xFF4B5563), // Shadow
            Color(0xFF9CA3AF), // Edge bounce
          ],
        ),
        boxShadow: [
          const BoxShadow(color: Colors.black87, blurRadius: 15, offset: Offset(0, 8)),
          BoxShadow(color: themeColor.withOpacity(0.5), blurRadius: 30, spreadRadius: -5),
        ],
        border: Border.all(color: const Color(0xFF2C3140), width: 3.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white38, width: 1.5),
            gradient: const RadialGradient(
              center: Alignment(-0.3, -0.4),
              radius: 0.8,
              colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8)],
            ),
          ),
          child: const Center(
            child: Text(
              '🍻',
              style: TextStyle(
                fontSize: 58,
                shadows: [Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 5))],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTapToDrawButton(Color themeColor, Color secondaryNeon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF0F1117),
        border: Border.all(color: themeColor, width: 2),
        boxShadow: [
          BoxShadow(color: themeColor.withOpacity(0.35), blurRadius: 20, spreadRadius: 1),
          BoxShadow(color: secondaryNeon.withOpacity(0.15), blurRadius: 30, spreadRadius: 5, offset: const Offset(0, 10)),
        ],
      ),
      child: Text(
        'TAP TO DRAW',
        style: TextStyle(
          color: themeColor,
          fontWeight: FontWeight.w900,
          fontSize: 16,
          letterSpacing: 2.0,
          shadows: [Shadow(color: themeColor, blurRadius: 10)],
        ),
      ),
    );
  }
}

class _TechPatternPainter extends CustomPainter {
  final Color color;
  _TechPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.04)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;
    for (double i = -size.height; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
      canvas.drawLine(Offset(i + size.height, 0), Offset(i, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
