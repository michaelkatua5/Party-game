import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/cheza_button.dart';
import '../../../shared/widgets/cheza_game_card.dart';
import '../../categories/providers/category_providers.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  int _currentIndex = 0;
  bool _showHint = false;

  @override
  Widget build(BuildContext context) {
    final wordsAsync = ref.watch(wordsProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'SOLO PRACTICE',
          style: AppTypography.h2.copyWith(letterSpacing: 1.2),
        ),
      ),
      body: SafeArea(
        child: wordsAsync.when(
          data: (words) {
            if (words.isEmpty) {
              return const Center(
                child: Text('No words available', style: TextStyle(color: Colors.white)),
              );
            }

            final currentWord = words[_currentIndex % words.length];

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
                vertical: AppDimensions.paddingM,
              ),
              child: Column(
                children: [
                  // Progress Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.darkCardBorder),
                    ),
                    child: Text(
                      'CARD ${_currentIndex + 1} OF ${words.length}',
                      style: AppTypography.micro.copyWith(color: AppColors.electricCyan),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Physical Game Card
                  ChezaGameCard(
                    word: currentWord,
                    categoryName: currentWord.categoryId.toUpperCase(),
                    categoryColor: AppColors.electricCyan,
                    isPractice: true,
                  ),

                  const SizedBox(height: 16),

                  // Optional Hint Reveal Box
                  if (_showHint)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.electricCyan.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.electricCyan.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Text('💡 ', style: TextStyle(fontSize: 16)),
                          Expanded(
                            child: Text(
                              currentWord.hints ?? 'Act it out without making a sound!',
                              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.25),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    TextButton.icon(
                      icon: const Icon(Icons.lightbulb_outline, color: AppColors.savannaGold, size: 18),
                      label: const Text('Show Acting Hint', style: TextStyle(color: AppColors.savannaGold)),
                      onPressed: () => setState(() => _showHint = true),
                    ),

                  const Spacer(flex: 2),

                  // Next Word Action
                  Row(
                    children: [
                      if (_currentIndex > 0)
                        Expanded(
                          flex: 1,
                          child: ChezaButton(
                            text: 'PREV',
                            variant: ChezaButtonVariant.secondary,
                            onPressed: () {
                              setState(() {
                                _currentIndex--;
                                _showHint = false;
                              });
                            },
                          ),
                        ),
                      if (_currentIndex > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ChezaButton(
                          text: 'NEXT WORD ➔',
                          variant: ChezaButtonVariant.primary,
                          onPressed: () {
                            setState(() {
                              _currentIndex++;
                              _showHint = false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.savannaGold),
          ),
          error: (_, __) => const Center(
            child: Text('Failed to load words', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
