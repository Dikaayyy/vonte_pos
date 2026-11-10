import '../entities/category.dart';

abstract class CategoryRepository {
  /// Retrieves all categories with their active product counts.
  Future<List<Category>> getCategories();

  /// Creates a new category after validating uniqueness (case-insensitive) and trimming.
  Future<Category> createCategory(String name);

  /// Updates an existing category name after validating uniqueness (case-insensitive) and trimming.
  Future<Category> updateCategory({
    required int id,
    required String name,
  });

  /// Deletes a category by id. Referencing products' category_id is set to null via ON DELETE SET NULL.
  Future<void> deleteCategory(int id);
}

