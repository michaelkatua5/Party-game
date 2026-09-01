import '../../domain/models/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/local_word_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final LocalWordDatasource datasource;

  CategoryRepositoryImpl({required this.datasource});

  @override
  Future<List<GameCategory>> getCategories({bool familyFriendlyOnly = false}) async {
    final categories = await datasource.loadCategories();
    final words = await datasource.loadWords();

    final enriched = categories.map((cat) {
      final count = words.where((w) => w.categoryId == cat.id).length;
      return cat.copyWith(cardCount: count);
    }).toList();

    if (familyFriendlyOnly) {
      return enriched.where((c) => c.isFamilyFriendly).toList();
    }
    return enriched;
  }

  @override
  Future<GameCategory?> getCategoryById(String id) async {
    final list = await getCategories();
    try {
      return list.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
