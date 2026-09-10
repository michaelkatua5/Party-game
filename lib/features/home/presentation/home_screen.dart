import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/haptic_service.dart';
import '../../settings/providers/settings_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  double _charadesTilt = 0.0;
  double _kingsCupTilt = 0.0;
  double _doOrDrinkTilt = 0.0;
  double _tapRouletteTilt = 0.0;
  bool _showLoadingOverlay = true;

  @override
  void initState() {
    super.initState();
    // Reduced artificial loading bar wait time significantly!
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showLoadingOverlay = false);
    });
  }

  bool _imagesPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPrecached) {
      precacheImage(const AssetImage('assets/images/charades_icon.jpg'), context);
      precacheImage(const AssetImage('assets/images/kings_cup_icon.jpg'), context);
      precacheImage(const AssetImage('assets/images/do_or_drink_icon.jpg'), context);
      precacheImage(const AssetImage('assets/images/tap_roulette_icon.jpg'), context);
      _imagesPrecached = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsNotifierProvider);
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
    final haptic = ref.read(hapticServiceProvider);
    final isDark = settings.isDarkMode;

    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textMain = isDark ? Colors.white : AppColors.textDark;
    final textSub = isDark ? AppColors.textMuted : const Color(0xFF64748B);

    final scaffold = Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Header: Branding + Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onLongPress: () {
                      haptic.trigger(HapticType.heavy);
                      context.push('/admin');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.savannaGold.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Text('🇰🇪', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 8),
                          Text(
                            'CHEZA!',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Action Icons in a styled pill container
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF151B28) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? const Color(0xFF232D42) : const Color(0xFFCBD5E1),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Theme Switcher Button (Light / Dark)
                        IconButton(
                          tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                          icon: Icon(
                            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            color: isDark ? AppColors.savannaGold : const Color(0xFF1E293B),
                            size: 20,
                          ),
                          onPressed: () {
                            haptic.trigger(HapticType.light);
                            settingsNotifier.toggleTheme();
                          },
                        ),
                        // How to play / Rules
                        IconButton(
                          tooltip: 'How to Play',
                          icon: Icon(Icons.help_outline_rounded, color: textSub, size: 20),
                          onPressed: () {
                            haptic.trigger(HapticType.selection);
                            context.push('/how-to-play');
                          },
                        ),
                        // Settings Icon
                        IconButton(
                          tooltip: 'Settings',
                          icon: Icon(Icons.settings_outlined, color: textSub, size: 20),
                          onPressed: () {
                            haptic.trigger(HapticType.selection);
                            context.push('/settings');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 2. Headline: CHOOSE YOUR GAME
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CHOOSE YOUR GAME',
                    style: AppTypography.h1.copyWith(
                      color: textMain,
                      fontSize: 32,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 6),
                  Text(
                    'Pick a party experience to start the chaos 🔥',
                    style: AppTypography.bodyMedium.copyWith(
                      color: textSub,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(begin: -0.05, end: 0),
                ],
              ),

              const SizedBox(height: 24),

              // 3. GAME 1: CHARADES (Act it. Don't say it.)
              MouseRegion(
                onEnter: (_) => setState(() => _charadesTilt = -0.015),
                onExit: (_) => setState(() => _charadesTilt = 0.0),
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _charadesTilt = -0.02),
                  onTapUp: (_) => setState(() => _charadesTilt = 0.0),
                  onTapCancel: () => setState(() => _charadesTilt = 0.0),
                  onTap: () {
                    haptic.trigger(HapticType.medium);
                    context.push('/player-setup');
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    height: 340,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateZ(_charadesTilt),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/charades_icon.jpg'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF2A6D).withOpacity(isDark ? 0.35 : 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 16),

              // 4. GAME 2: KINGS CUP (Draw. Dare. Survive.)
              MouseRegion(
                onEnter: (_) => setState(() => _kingsCupTilt = 0.015),
                onExit: (_) => setState(() => _kingsCupTilt = 0.0),
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _kingsCupTilt = 0.02),
                  onTapUp: (_) => setState(() => _kingsCupTilt = 0.0),
                  onTapCancel: () => setState(() => _kingsCupTilt = 0.0),
                  onTap: () {
                    haptic.trigger(HapticType.medium);
                    context.push('/kings-cup/setup');
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    height: 340,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateZ(_kingsCupTilt),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/kings_cup_icon.jpg'),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        color: AppColors.savannaGold.withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.savannaGold.withOpacity(isDark ? 0.15 : 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().scale(delay: 100.ms, duration: 350.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 16),

              // 5. GAME 3: DO OR DRINK
              MouseRegion(
                onEnter: (_) => setState(() => _doOrDrinkTilt = 0.015),
                onExit: (_) => setState(() => _doOrDrinkTilt = 0.0),
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _doOrDrinkTilt = 0.02),
                  onTapUp: (_) => setState(() => _doOrDrinkTilt = 0.0),
                  onTapCancel: () => setState(() => _doOrDrinkTilt = 0.0),
                  onTap: () {
                    haptic.trigger(HapticType.medium);
                    context.push('/do-or-drink/setup');
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    height: 340,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateZ(_doOrDrinkTilt),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/do_or_drink_icon.jpg'),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        color: const Color(0xFF38BDF8).withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF38BDF8).withOpacity(isDark ? 0.15 : 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().scale(delay: 200.ms, duration: 350.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 16),
              // Tap Roulette Card Addition
              MouseRegion(
                onEnter: (_) => setState(() => _tapRouletteTilt = 0.015),
                onExit: (_) => setState(() => _tapRouletteTilt = 0.0),
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _tapRouletteTilt = 0.02),
                  onTapUp: (_) => setState(() => _tapRouletteTilt = 0.0),
                  onTapCancel: () => setState(() => _tapRouletteTilt = 0.0),
                  onTap: () {
                    haptic.trigger(HapticType.medium);
                    context.push('/tap-roulette');
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    height: 340,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateZ(_tapRouletteTilt),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/tap_roulette_icon.jpg'),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        color: AppColors.cyberPink.withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyberPink.withOpacity(isDark ? 0.15 : 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().scale(delay: 300.ms, duration: 350.ms, curve: Curves.easeOutBack),
            ],
          ),
        ),
      ),
    );

    return Stack(
      children: [
        scaffold,
        // Loading overlay — shown briefly on first app open, then fades away
        AnimatedOpacity(
          opacity: _showLoadingOverlay ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 600),
          child: IgnorePointer(
            ignoring: !_showLoadingOverlay,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/splash_bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 48),
                      child: Column(
                        children: [
                          const Text(
                            'LOADING...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                            ),
                          ).animate(onPlay: (c) => c.repeat()).shimmer(
                                duration: 1500.ms,
                                color: const Color(0xFF38BDF8).withOpacity(0.5),
                              ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: 200,
                            height: 8,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 2000),
                                curve: Curves.easeInOut,
                                builder: (context, value, _) {
                                  return LinearProgressIndicator(
                                    value: value,
                                    backgroundColor: Colors.black54,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      Color(0xFF38BDF8),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
