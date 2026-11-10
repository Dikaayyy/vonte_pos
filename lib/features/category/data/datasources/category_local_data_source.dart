import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/error/exceptions.dart';
import '../models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getCategories();

  Future<CategoryModel?> findCategoryByName(String name, {int? excludeId});

  Future<CategoryModel> createCategory(String name);

  Future<CategoryModel> updateCategory({
    required int id,
    required String name,
  });

  Future<void> deleteCategory(int id);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final AppDatabase _appDatabase;

  CategoryLocalDataSourceImpl(this._appDatabase);

  Future<Database> get _db => _appDatabase.database;

  @override
  Future<List<CategoryModel>> getCategories() async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT 
        c.id, 
        c.name, 
        COUNT(p.id) AS product_count
      FROM ${AppTables.categories} c
      LEFT JOIN ${AppTables.products} p 
        ON p.category_id = c.id AND p.is_deleted = 0
      GROUP BY c.id, c.name
      ORDER BY c.name COLLATE NOCASE ASC
    ''');

    return results.map(CategoryModel.fromMap).toList();
  }

  @override
  Future<CategoryModel?> findCategoryByName(
    String name, {
    int? excludeId,
  }) async {
    final db = await _db;
    final results = await db.rawQuery(
      '''
      SELECT id, name FROM ${AppTables.categories}
      WHERE LOWER(TRIM(name)) = LOWER(TRIM(?))
        AND (? IS NULL OR id != ?)
      LIMIT 1
      ''',
      [name, excludeId, excludeId],
    );

    if (results.isEmpty) {
      return null;
    }
    return CategoryModel.fromMap(results.first);
  }

  @override
  Future<CategoryModel> createCategory(String name) async {
    final db = await _db;
    final id = await db.insert(
      AppTables.categories,
      {'name': name},
    );

    return CategoryModel(id: id, name: name, productCount: 0);
  }

  @override
  Future<CategoryModel> updateCategory({
    required int id,
    required String name,
  }) async {
    final db = await _db;
    final affected = await db.update(
      AppTables.categories,
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );

    if (affected == 0) {
      throw const AppDatabaseException('Kategori tidak ditemukan.');
    }

    final countResult = await db.rawQuery(
      'SELECT COUNT(id) AS product_count FROM ${AppTables.products} WHERE category_id = ? AND is_deleted = 0',
      [id],
    );
    final count = Sqflite.firstIntValue(countResult) ?? 0;

    return CategoryModel(id: id, name: name, productCount: count);
  }

  @override
  Future<void> deleteCategory(int id) async {
    final db = await _db;
    final affected = await db.delete(
      AppTables.categories,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (affected == 0) {
      throw const AppDatabaseException('Kategori tidak ditemukan.');
    }
  }
}
