import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../domain/models/word.dart';
import '../../../shared/widgets/category_badge.dart';
import '../../../shared/widgets/kenyan_button.dart';
import '../../../core/providers/core_providers.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  List<GameWord> _deck = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final wordRepo = ref.read(wordRepositoryProvider);
    final words = await wordRepo.getAllWords();
    final shuffled = List<GameWord>.from(words)..shuffle();
    if (mounted) {
      setState(() {
        _deck = shuffled;
        _isLoading = false;
      });
    }
  }

  void _nextCard() {
    if (_deck.isNotEmpty) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _deck.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentWord = _deck.isNotEmpty ? _deck[_currentIndex] : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎯 Solo Practice & Discovery'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            children: [
              const Text(
                'Explore Kenyan words, test your acting techniques, and learn Sheng slang meanings!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Word Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                    border: Border.all(color: AppColors.darkCardBorder, width: 2),
                  ),
                  child: currentWord == null
                      ? const Center(child: Text('No words loaded'))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CategoryBadge(
                              label: currentWord.categoryId.toUpperCase(),
                              color: AppColors.savannaGold,
                            ),
                            const Spacer(),
                            Text(
                              currentWord.word,
                              textAlign: TextAlign.center,
                              style: AppTypography.gameWordCard,
                            ),
                            const SizedBox(height: 16),
                            if (currentWord.hints.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.darkInput,
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                                ),
                                child: Text(
                                  '💡 ${currentWord.hints}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            const Spacer(),
                            Text(
                              'Card ${_currentIndex + 1} of ${_deck.length}',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

              KenyanButton(
                text: 'NEXT CARD ➡️',
                gradient: AppColors.primaryGradient,
                onPressed: _nextCard,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
