import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/friends_illustration.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2400));
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0B1E), // Deep party purple-black
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Title Branding: CHEZA! with Party Mask Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF8B5CF6),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🎭', style: TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'CHEZA!',
                      style: AppTypography.gameTitle.copyWith(
                        fontSize: 48,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

                const SizedBox(height: 6),

                Text(
                  'PLAY. LAUGH. REPEAT.',
                  style: TextStyle(
                    color: AppColors.savannaGold,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 48),

                // 4 Friends Celebrating Illustration
                const FriendsIllustration(height: 160)
                    .animate()
                    .fadeIn(delay: 350.ms)
                    .slideY(begin: 0.1, end: 0),

                const Spacer(),

                // Loading Bar matching Blueprint Screen 1
                Column(
                  children: [
                    const Text(
                      'LOADING...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 180,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const LinearProgressIndicator(
                          minHeight: 8,
                          backgroundColor: Color(0xFF1F1B33),
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
