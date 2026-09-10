import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/word.dart';

final categoriesFutureProvider = FutureProvider<List<GameCategory>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return await repo.getCategories();
});

final categoriesProvider = categoriesFutureProvider;

final wordsProvider = FutureProvider<List<GameWord>>((ref) async {
  final repo = ref.watch(wordRepositoryProvider);
  return await repo.getAllWords();
});

final selectedCategoryFilterProvider = StateProvider<List<String>>((ref) {
  return [];
});
