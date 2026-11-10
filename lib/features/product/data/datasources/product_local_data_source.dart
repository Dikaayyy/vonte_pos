import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getProducts({
    int? categoryId,
    String? query,
    bool includeDeleted = false,
  });

  Future<ProductModel?> getProductById(int id);

  Future<ProductModel> createProduct({
    required String name,
    int? categoryId,
    required int price,
    required int stock,
    String? photoPath,
    List<int> addonIds = const [],
  });

  Future<ProductModel> updateProduct({
    required int id,
    required String name,
    int? categoryId,
    required int price,
    required int stock,
    String? photoPath,
    List<int> addonIds = const [],
  });

  Future<void> deleteProduct(int id);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final AppDatabase _appDatabase;

  ProductLocalDataSourceImpl(this._appDatabase);

  Future<Database> get _db => _appDatabase.database;

  @override
  Future<List<ProductModel>> getProducts({
    int? categoryId,
    String? query,
    bool includeDeleted = false,
  }) async {
    final db = await _db;
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (!includeDeleted) {
      whereClauses.add('p.is_deleted = 0');
    }

    if (categoryId != null) {
      whereClauses.add('p.category_id = ?');
      whereArgs.add(categoryId);
    }

    if (query != null && query.trim().isNotEmpty) {
      whereClauses.add('LOWER(p.name) LIKE ?');
      whereArgs.add('%${query.trim().toLowerCase()}%');
    }

    final whereString = whereClauses.isNotEmpty
        ? 'WHERE ${whereClauses.join(' AND ')}'
        : '';

    final results = await db.rawQuery('''
      SELECT 
        p.id, 
        p.category_id, 
        c.name AS category_name, 
        p.name, 
        p.price, 
        p.stock, 
        p.photo_path, 
        p.is_deleted, 
        p.created_at, 
        p.updated_at
      FROM ${AppTables.products} p
      LEFT JOIN ${AppTables.categories} c ON c.id = p.category_id
      $whereString
      ORDER BY p.name COLLATE NOCASE ASC
    ''', whereArgs);

    if (results.isEmpty) {
      return [];
    }

    // Fetch addon mappings for the returned products in one query
    final productIds = results.map((r) => r['id'] as int).toList();
    final placeholders = List.filled(productIds.length, '?').join(',');
    final addonResults = await db.rawQuery('''
      SELECT product_id, addon_id 
      FROM ${AppTables.productAddons}
      WHERE product_id IN ($placeholders)
    ''', productIds);

    final addonMap = <int, List<int>>{};
    for (final row in addonResults) {
      final pId = row['product_id'] as int;
      final aId = row['addon_id'] as int;
      addonMap.putIfAbsent(pId, () => []).add(aId);
    }

    return results
        .map((row) => ProductModel.fromMap(
              row,
              addonIds: addonMap[row['id'] as int] ?? const [],
            ))
        .toList();
  }

  @override
  Future<ProductModel?> getProductById(int id) async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT 
        p.id, 
        p.category_id, 
        c.name AS category_name, 
        p.name, 
        p.price, 
        p.stock, 
        p.photo_path, 
        p.is_deleted, 
        p.created_at, 
        p.updated_at
      FROM ${AppTables.products} p
      LEFT JOIN ${AppTables.categories} c ON c.id = p.category_id
      WHERE p.id = ?
      LIMIT 1
    ''', [id]);

    if (results.isEmpty) {
      return null;
    }

    final addonResults = await db.query(
      AppTables.productAddons,
      columns: ['addon_id'],
      where: 'product_id = ?',
      whereArgs: [id],
    );
    final addonIds = addonResults.map((r) => r['addon_id'] as int).toList();

    return ProductModel.fromMap(results.first, addonIds: addonIds);
  }

  @override
  Future<ProductModel> createProduct({
    required String name,
    int? categoryId,
    required int price,
    required int stock,
    String? photoPath,
    List<int> addonIds = const [],
  }) async {
    final db = await _db;
    return db.transaction((txn) async {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      final productId = await txn.insert(
        AppTables.products,
        {
          'category_id': categoryId,
          'name': name.trim(),
          'price': price,
          'stock': stock,
          'photo_path': photoPath,
          'is_deleted': 0,
          'created_at': now,
          'updated_at': now,
        },
      );

      for (final addonId in addonIds) {
        await txn.insert(
          AppTables.productAddons,
          {
            'product_id': productId,
            'addon_id': addonId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      String? categoryName;
      if (categoryId != null) {
        final catRes = await txn.query(
          AppTables.categories,
          columns: ['name'],
          where: 'id = ?',
          whereArgs: [categoryId],
          limit: 1,
        );
        if (catRes.isNotEmpty) {
          categoryName = catRes.first['name'] as String?;
        }
      }

      return ProductModel(
        id: productId,
        categoryId: categoryId,
        categoryName: categoryName,
        name: name.trim(),
        price: price,
        stock: stock,
        photoPath: photoPath,
        addonIds: addonIds,
        isDeleted: false,
        createdAt: now,
        updatedAt: now,
      );
    });
  }

  @override
  Future<ProductModel> updateProduct({
    required int id,
    required String name,
    int? categoryId,
    required int price,
    required int stock,
    String? photoPath,
    List<int> addonIds = const [],
  }) async {
    final db = await _db;
    return db.transaction((txn) async {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      final affected = await txn.update(
        AppTables.products,
        {
          'category_id': categoryId,
          'name': name.trim(),
          'price': price,
          'stock': stock,
          'photo_path': photoPath,
          'updated_at': now,
        },
        where: 'id = ? AND is_deleted = 0',
        whereArgs: [id],
      );

      if (affected == 0) {
        throw const AppDatabaseException('Produk tidak ditemukan.');
      }

      await txn.delete(
        AppTables.productAddons,
        where: 'product_id = ?',
        whereArgs: [id],
      );

      for (final addonId in addonIds) {
        await txn.insert(
          AppTables.productAddons,
          {
            'product_id': id,
            'addon_id': addonId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      final pRes = await txn.rawQuery('''
        SELECT p.created_at, c.name AS category_name
        FROM ${AppTables.products} p
        LEFT JOIN ${AppTables.categories} c ON c.id = p.category_id
        WHERE p.id = ?
      ''', [id]);

      final createdAt =
          pRes.isNotEmpty ? pRes.first['created_at'] as int : now;
      final categoryName =
          pRes.isNotEmpty ? pRes.first['category_name'] as String? : null;

      return ProductModel(
        id: id,
        categoryId: categoryId,
        categoryName: categoryName,
        name: name.trim(),
        price: price,
        stock: stock,
        photoPath: photoPath,
        addonIds: addonIds,
        isDeleted: false,
        createdAt: createdAt,
        updatedAt: now,
      );
    });
  }

  @override
  Future<void> deleteProduct(int id) async {
    final db = await _db;
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final affected = await db.update(
      AppTables.products,
      {
        'is_deleted': 1,
        'updated_at': now,
      },
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );

    if (affected == 0) {
      throw const AppDatabaseException('Produk tidak ditemukan.');
    }
  }
}

