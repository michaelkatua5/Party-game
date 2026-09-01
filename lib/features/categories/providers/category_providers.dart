import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../domain/models/category.dart';

final categoriesFutureProvider = FutureProvider<List<GameCategory>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return await repo.getCategories();
});

final selectedCategoryFilterProvider = StateProvider<List<String>>((ref) {
  return [];
});
