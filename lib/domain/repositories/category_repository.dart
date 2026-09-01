import '../models/category.dart';

abstract class CategoryRepository {
  Future<List<GameCategory>> getCategories({bool familyFriendlyOnly = false});
  Future<GameCategory?> getCategoryById(String id);
}
