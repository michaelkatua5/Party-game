import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/models/word.dart';
import '../../domain/models/category.dart';

class LocalWordDatasource {
  List<GameWord>? _cachedWords;
  List<GameCategory>? _cachedCategories;

  Future<List<GameCategory>> loadCategories() async {
    if (_cachedCategories != null) return _cachedCategories!;

    try {
      final jsonString = await rootBundle.loadString('assets/data/categories.json');
      final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
      _cachedCategories = list
          .map((item) => GameCategory.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Fallback categories if rootBundle is unavailable (e.g. standard tests)
      _cachedCategories = _fallbackCategories;
    }
    return _cachedCategories!;
  }

  Future<List<GameWord>> loadWords() async {
    if (_cachedWords != null) return _cachedWords!;

    try {
      final jsonString = await rootBundle.loadString('assets/data/words.json');
      final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
      _cachedWords = list
          .map((item) => GameWord.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _cachedWords = _fallbackWords;
    }
    return _cachedWords!;
  }

  static const List<GameCategory> _fallbackCategories = [
    GameCategory(
      id: 'sheng',
      name: 'Kenyan Slang & Sheng',
      nameSw: 'Misemo ya Sheng',
      description: 'Street slang and Nairobi lingo.',
      icon: 'chatbubble_ellipses',
      color: '#E63946',
    ),
    GameCategory(
      id: 'food',
      name: 'Kenyan Food & Delicacies',
      nameSw: 'Vyakula vya Kenya',
      description: 'Local dishes and street bites.',
      icon: 'restaurant',
      color: '#FB8500',
    ),
  ];

  static const List<GameWord> _fallbackWords = [
    GameWord(
      id: 'sheng_001',
      word: 'Kula Fare',
      categoryId: 'sheng',
      difficulty: 'easy',
      hints: 'Taking fare and not showing up',
    ),
    GameWord(
      id: 'food_001',
      word: 'Mutura',
      categoryId: 'food',
      difficulty: 'easy',
      hints: 'Evening roasted street delicacy',
    ),
  ];
}
