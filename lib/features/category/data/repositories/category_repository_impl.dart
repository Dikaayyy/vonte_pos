import 'package:sqflite/sqflite.dart' as sqflite;

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_data_source.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource _localDataSource;

  CategoryRepositoryImpl(this._localDataSource);

  @override
  Future<List<Category>> getCategories() async {
    return _localDataSource.getCategories();
  }

  @override
  Future<Category> createCategory(String name) async {
    final trimmed = name.trim();
    final existing = await _localDataSource.findCategoryByName(trimmed);
    if (existing != null) {
      throw const ValidationException(AppStrings.categoryNameDuplicate);
    }

    try {
      return await _localDataSource.createCategory(trimmed);
    } on sqflite.DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw const ValidationException(AppStrings.categoryNameDuplicate);
      }
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<Category> updateCategory({
    required int id,
    required String name,
  }) async {
    final trimmed = name.trim();
    final existing = await _localDataSource.findCategoryByName(
      trimmed,
      excludeId: id,
    );
    if (existing != null) {
      throw const ValidationException(AppStrings.categoryNameDuplicate);
    }

    try {
      return await _localDataSource.updateCategory(id: id, name: trimmed);
    } on sqflite.DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw const ValidationException(AppStrings.categoryNameDuplicate);
      }
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    try {
      await _localDataSource.deleteCategory(id);
    } on sqflite.DatabaseException catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }
}

