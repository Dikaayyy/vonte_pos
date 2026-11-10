import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/core/database/app_database.dart';
import 'package:vonte_pos/core/database/tables.dart';
import 'package:vonte_pos/core/error/exceptions.dart';
import 'package:vonte_pos/features/category/data/datasources/category_local_data_source.dart';
import 'package:vonte_pos/features/category/data/repositories/category_repository_impl.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('CategoryRepositoryImpl with In-Memory SQLite Database', () {
    late AppDatabase appDb;
    late Database db;
    late CategoryLocalDataSource dataSource;
    late CategoryRepositoryImpl repository;

    setUp(() async {
      appDb = AppDatabase.inMemory();
      db = await appDb.database;
      dataSource = CategoryLocalDataSourceImpl(appDb);
      repository = CategoryRepositoryImpl(dataSource);
    });

    tearDown(() async {
      await appDb.close();
    });

    test('createCategory stores trimmed category in database', () async {
      final category = await repository.createCategory('  Minuman  ');

      expect(category.id, greaterThan(0));
      expect(category.name, equals('Minuman'));
      expect(category.productCount, equals(0));

      final rows = await db.query(
        AppTables.categories,
        where: 'id = ?',
        whereArgs: [category.id],
      );
      expect(rows.length, equals(1));
      expect(rows.first['name'], equals('Minuman'));
    });

    test('duplikat nama kategori dicegah tanpa membedakan huruf besar kecil (case-insensitive)', () async {
      await repository.createCategory('Makanan');

      // Attempt exact duplicate
      expect(
        () => repository.createCategory('Makanan'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            AppStrings.categoryNameDuplicate,
          ),
        ),
      );

      // Attempt lowercase duplicate
      expect(
        () => repository.createCategory('makanan'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            AppStrings.categoryNameDuplicate,
          ),
        ),
      );

      // Attempt duplicate with extra whitespace and uppercase
      expect(
        () => repository.createCategory('   MAKANAN   '),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            AppStrings.categoryNameDuplicate,
          ),
        ),
      );
    });

    test('updateCategory prevents duplicate name from another category', () async {
      final cat1 = await repository.createCategory('Minuman Panas');
      final cat2 = await repository.createCategory('Minuman Dingin');

      // Rename cat2 to cat1 name case-insensitively
      expect(
        () => repository.updateCategory(
          id: cat2.id,
          name: 'minuman panas',
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            AppStrings.categoryNameDuplicate,
          ),
        ),
      );

      // Renaming cat1 to its own name with updated case is allowed
      final updatedCat1 = await repository.updateCategory(
        id: cat1.id,
        name: 'Minuman PANAS',
      );
      expect(updatedCat1.name, equals('Minuman PANAS'));
    });

    test('getCategories returns category list with active product counts and excludes soft-deleted', () async {
      final cat1 = await repository.createCategory('Kopi');
      final cat2 = await repository.createCategory('Teh');

      final now = DateTime.now().toUtc().millisecondsSinceEpoch;

      // Insert 2 active products for cat1
      await db.insert(AppTables.products, {
        'category_id': cat1.id,
        'name': 'Espresso',
        'price': 18000,
        'stock': 10,
        'is_deleted': 0,
        'created_at': now,
        'updated_at': now,
      });
      await db.insert(AppTables.products, {
        'category_id': cat1.id,
        'name': 'Latte',
        'price': 24000,
        'stock': 15,
        'is_deleted': 0,
        'created_at': now,
        'updated_at': now,
      });

      // Insert 1 soft-deleted product for cat1
      await db.insert(AppTables.products, {
        'category_id': cat1.id,
        'name': 'Kopi Lawas (Deleted)',
        'price': 10000,
        'stock': 0,
        'is_deleted': 1,
        'created_at': now,
        'updated_at': now,
      });

      // Insert 1 active product for cat2
      await db.insert(AppTables.products, {
        'category_id': cat2.id,
        'name': 'Earl Grey',
        'price': 20000,
        'stock': 8,
        'is_deleted': 0,
        'created_at': now,
        'updated_at': now,
      });

      final categories = await repository.getCategories();
      expect(categories.length, equals(2));

      final kopi = categories.firstWhere((c) => c.name == 'Kopi');
      final teh = categories.firstWhere((c) => c.name == 'Teh');

      // cat1 should have 2 active products (soft-deleted is excluded)
      expect(kopi.productCount, equals(2));
      // cat2 should have 1 active product
      expect(teh.productCount, equals(1));
    });

    test('hapus kategori yang punya produk: category_id menjadi NULL (ON DELETE SET NULL), produk tidak dihapus', () async {
      final cat = await repository.createCategory('Pastry');
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;

      // Insert products under Pastry
      final prod1Id = await db.insert(AppTables.products, {
        'category_id': cat.id,
        'name': 'Croissant',
        'price': 25000,
        'stock': 12,
        'is_deleted': 0,
        'created_at': now,
        'updated_at': now,
      });
      final prod2Id = await db.insert(AppTables.products, {
        'category_id': cat.id,
        'name': 'Danish',
        'price': 28000,
        'stock': 6,
        'is_deleted': 0,
        'created_at': now,
        'updated_at': now,
      });

      // Delete category
      await repository.deleteCategory(cat.id);

      // Verify category is deleted from categories table
      final catRows = await db.query(
        AppTables.categories,
        where: 'id = ?',
        whereArgs: [cat.id],
      );
      expect(catRows, isEmpty);

      // Verify products STILL EXIST in the products table
      final prodRows = await db.query(
        AppTables.products,
        where: 'id IN (?, ?)',
        whereArgs: [prod1Id, prod2Id],
      );
      expect(prodRows.length, equals(2));

      // Verify their category_id is now NULL and is_deleted remains 0
      for (final row in prodRows) {
        expect(row['category_id'], isNull);
        expect(row['is_deleted'], equals(0));
      }
    });
  });
}

