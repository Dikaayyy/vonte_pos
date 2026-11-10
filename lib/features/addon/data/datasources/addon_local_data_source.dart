import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/error/exceptions.dart';
import '../models/addon_model.dart';

abstract class AddonLocalDataSource {
  Future<List<AddonModel>> getAddons({bool includeDeleted = false});

  Future<AddonModel?> getAddonById(int id);

  Future<AddonModel> createAddon({
    required String name,
    required int price,
    required int stock,
  });

  Future<AddonModel> updateAddon({
    required int id,
    required String name,
    required int price,
    required int stock,
  });

  Future<void> deleteAddon(int id);
}

class AddonLocalDataSourceImpl implements AddonLocalDataSource {
  final AppDatabase _appDatabase;

  AddonLocalDataSourceImpl(this._appDatabase);

  Future<Database> get _db => _appDatabase.database;

  @override
  Future<List<AddonModel>> getAddons({bool includeDeleted = false}) async {
    final db = await _db;
    final String query;
    if (includeDeleted) {
      query = 'SELECT * FROM ${AppTables.addons} ORDER BY name COLLATE NOCASE ASC';
    } else {
      query =
          'SELECT * FROM ${AppTables.addons} WHERE is_deleted = 0 ORDER BY name COLLATE NOCASE ASC';
    }

    final results = await db.rawQuery(query);
    return results.map(AddonModel.fromMap).toList();
  }

  @override
  Future<AddonModel?> getAddonById(int id) async {
    final db = await _db;
    final results = await db.query(
      AppTables.addons,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }
    return AddonModel.fromMap(results.first);
  }

  @override
  Future<AddonModel> createAddon({
    required String name,
    required int price,
    required int stock,
  }) async {
    final db = await _db;
    final id = await db.insert(
      AppTables.addons,
      {
        'name': name,
        'price': price,
        'stock': stock,
        'is_deleted': 0,
      },
    );

    return AddonModel(
      id: id,
      name: name,
      price: price,
      stock: stock,
      isDeleted: false,
    );
  }

  @override
  Future<AddonModel> updateAddon({
    required int id,
    required String name,
    required int price,
    required int stock,
  }) async {
    final db = await _db;
    final affected = await db.update(
      AppTables.addons,
      {
        'name': name,
        'price': price,
        'stock': stock,
      },
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );

    if (affected == 0) {
      throw const AppDatabaseException('Add-on tidak ditemukan.');
    }

    return AddonModel(
      id: id,
      name: name,
      price: price,
      stock: stock,
      isDeleted: false,
    );
  }

  @override
  Future<void> deleteAddon(int id) async {
    final db = await _db;
    // Soft delete: is_deleted = 1
    final affected = await db.update(
      AppTables.addons,
      {'is_deleted': 1},
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );

    if (affected == 0) {
      throw const AppDatabaseException('Add-on tidak ditemukan.');
    }
  }
}

