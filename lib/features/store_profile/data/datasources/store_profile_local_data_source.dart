import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/error/exceptions.dart';
import '../models/store_profile_model.dart';

abstract class StoreProfileLocalDataSource {
  Future<StoreProfileModel> getStoreProfile();

  Future<StoreProfileModel> updateStoreProfile(StoreProfileModel model);

  Future<bool> isCatalogEmpty();

  Future<bool> seedSampleData();
}

class StoreProfileLocalDataSourceImpl implements StoreProfileLocalDataSource {
  final AppDatabase _appDatabase;

  StoreProfileLocalDataSourceImpl(this._appDatabase);

  Future<Database> get _db => _appDatabase.database;

  @override
  Future<StoreProfileModel> getStoreProfile() async {
    final db = await _db;
    final results = await db.query(
      AppTables.storeProfile,
      limit: 1,
    );

    if (results.isEmpty) {
      final id = await db.insert(AppTables.storeProfile, {
        'name': 'Vonte PoS',
        'address': 'Jl. Bisnis No. 1',
        'phone': '081234567890',
        'receipt_footer': 'Terima kasih atas kunjungan Anda',
      });
      return StoreProfileModel(
        id: id,
        name: 'Vonte PoS',
        address: 'Jl. Bisnis No. 1',
        phone: '081234567890',
        receiptFooter: 'Terima kasih atas kunjungan Anda',
      );
    }

    return StoreProfileModel.fromMap(results.first);
  }

  @override
  Future<StoreProfileModel> updateStoreProfile(StoreProfileModel model) async {
    final db = await _db;
    final affected = await db.update(
      AppTables.storeProfile,
      {
        'name': model.name,
        'address': model.address,
        'phone': model.phone,
        'receipt_footer': model.receiptFooter,
      },
      where: 'id = ?',
      whereArgs: [model.id],
    );

    if (affected == 0) {
      throw const AppDatabaseException('Profil toko tidak ditemukan.');
    }

    return model;
  }

  @override
  Future<bool> isCatalogEmpty() async {
    final db = await _db;
    final prodCount = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(id) FROM ${AppTables.products} WHERE is_deleted = 0',
          ),
        ) ??
        0;

    return prodCount == 0;
  }

  @override
  Future<bool> seedSampleData() async {
    final db = await _db;
    return db.transaction((txn) async {
      final activeProdCount = Sqflite.firstIntValue(
            await txn.rawQuery(
              'SELECT COUNT(id) FROM ${AppTables.products} WHERE is_deleted = 0',
            ),
          ) ??
          0;

      // Seed only when there are no active products in the catalog.
      if (activeProdCount > 0) {
        return false;
      }

      final now = DateTime.now().toUtc().millisecondsSinceEpoch;

      // Helper to reuse existing category or insert new one without duplicate constraint collision
      Future<int> getOrCreateCategory(String name) async {
        final existing = await txn.query(
          AppTables.categories,
          columns: ['id'],
          where: 'LOWER(TRIM(name)) = LOWER(TRIM(?))',
          whereArgs: [name],
          limit: 1,
        );
        if (existing.isNotEmpty) {
          return existing.first['id'] as int;
        }
        return txn.insert(AppTables.categories, {'name': name});
      }

      // Helper to reuse/reactivate existing addon or insert new one
      Future<int> getOrCreateAddon(String name, int price, int stock) async {
        final existing = await txn.query(
          AppTables.addons,
          columns: ['id'],
          where: 'LOWER(TRIM(name)) = LOWER(TRIM(?))',
          whereArgs: [name],
          limit: 1,
        );
        if (existing.isNotEmpty) {
          final id = existing.first['id'] as int;
          await txn.update(
            AppTables.addons,
            {'is_deleted': 0, 'price': price, 'stock': stock},
            where: 'id = ?',
            whereArgs: [id],
          );
          return id;
        }
        return txn.insert(AppTables.addons, {
          'name': name,
          'price': price,
          'stock': stock,
          'is_deleted': 0,
        });
      }

      // 1. Categories
      final catKopiId = await getOrCreateCategory('Kopi');
      final catNonKopiId = await getOrCreateCategory('Non-Kopi');
      final catRotiId = await getOrCreateCategory('Roti & Kudapan');

      // 2. Add-ons
      final addonShotId = await getOrCreateAddon('Extra Shot', 4000, 50);
      final addonArenId = await getOrCreateAddon('Gula Aren', 2000, 40);
      final addonOatId = await getOrCreateAddon('Susu Oat', 6000, 30);
      final addonKejuId = await getOrCreateAddon('Keju Parut', 3000, 25);

      // 3. Products
      final prodKopiSusuId = await txn.insert(AppTables.products, {
        'category_id': catKopiId,
        'name': 'Kopi Susu Aren',
        'price': 18000,
        'stock': 35,
        'photo_path': null,
        'is_deleted': 0,
        'created_at': now,
        'updated_at': now,
      });

      final prodAmericanoId = await txn.insert(AppTables.products, {
        'category_id': catKopiId,
        'name': 'Americano',
        'price': 15000,
        'stock': 30,
        'photo_path': null,
        'is_deleted': 0,
        'created_at': now,
        'updated_at': now,
      });

      final prodMatchaId = await txn.insert(AppTables.products, {
        'category_id': catNonKopiId,
        'name': 'Matcha Latte',
        'price': 20000,
        'stock': 25,
        'photo_path': null,
        'is_deleted': 0,
        'created_at': now,
        'updated_at': now,
      });

      final prodRotiBakarId = await txn.insert(AppTables.products, {
        'category_id': catRotiId,
        'name': 'Roti Bakar Cokelat Keju',
        'price': 22000,
        'stock': 20,
        'photo_path': null,
        'is_deleted': 0,
        'created_at': now,
        'updated_at': now,
      });

      await txn.insert(AppTables.products, {
        'category_id': catRotiId,
        'name': 'Croissant Butter',
        'price': 16000,
        'stock': 15,
        'photo_path': null,
        'is_deleted': 0,
        'created_at': now,
        'updated_at': now,
      });

      // 4. Product Add-on links
      for (final addonId in [addonShotId, addonArenId, addonOatId]) {
        await txn.insert(
          AppTables.productAddons,
          {
            'product_id': prodKopiSusuId,
            'addon_id': addonId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await txn.insert(
        AppTables.productAddons,
        {
          'product_id': prodAmericanoId,
          'addon_id': addonShotId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.insert(
        AppTables.productAddons,
        {
          'product_id': prodMatchaId,
          'addon_id': addonOatId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.insert(
        AppTables.productAddons,
        {
          'product_id': prodRotiBakarId,
          'addon_id': addonKejuId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return true;
    });
  }
}

