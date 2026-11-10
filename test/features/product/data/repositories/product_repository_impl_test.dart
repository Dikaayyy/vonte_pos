import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vonte_pos/core/database/app_database.dart';
import 'package:vonte_pos/core/database/tables.dart';
import 'package:vonte_pos/core/error/exceptions.dart';
import 'package:vonte_pos/features/product/data/datasources/product_local_data_source.dart';
import 'package:vonte_pos/features/product/data/repositories/product_repository_impl.dart';
import 'package:vonte_pos/features/product/data/services/photo_storage.dart';

class MockPhotoStorage extends Mock implements PhotoStorage {}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('ProductRepositoryImpl with In-Memory SQLite Database', () {
    late AppDatabase appDb;
    late Database db;
    late ProductLocalDataSource dataSource;
    late MockPhotoStorage mockPhotoStorage;
    late ProductRepositoryImpl repository;

    setUp(() async {
      appDb = AppDatabase.inMemory();
      db = await appDb.database;
      dataSource = ProductLocalDataSourceImpl(appDb);
      mockPhotoStorage = MockPhotoStorage();
      repository = ProductRepositoryImpl(dataSource, mockPhotoStorage);

      when(() => mockPhotoStorage.deletePhoto(any())).thenAnswer((_) async {});
    });

    tearDown(() async {
      await appDb.close();
    });

    test('createProduct stores product and attaches addons in pivot table', () async {
      // 1. Seed a category and two addons
      final catId = await db.insert(AppTables.categories, {'name': 'Minuman'});
      final addon1Id = await db.insert(AppTables.addons, {
        'name': 'Extra Shot',
        'price': 4000,
        'stock': 10,
        'is_deleted': 0,
      });
      final addon2Id = await db.insert(AppTables.addons, {
        'name': 'Oat Milk',
        'price': 6000,
        'stock': 5,
        'is_deleted': 0,
      });

      final product = await repository.createProduct(
        name: 'Kopi Latte',
        categoryId: catId,
        price: 24000,
        stock: 12,
        photoPath: 'product_images/latte.jpg',
        addonIds: [addon1Id, addon2Id],
      );

      expect(product.id, greaterThan(0));
      expect(product.name, 'Kopi Latte');
      expect(product.categoryId, catId);
      expect(product.categoryName, 'Minuman');
      expect(product.price, 24000);
      expect(product.stock, 12);
      expect(product.photoPath, 'product_images/latte.jpg');
      expect(product.addonIds, containsAll([addon1Id, addon2Id]));
      expect(product.isDeleted, isFalse);

      // Verify database row
      final pRows = await db.query(
        AppTables.products,
        where: 'id = ?',
        whereArgs: [product.id],
      );
      expect(pRows.length, 1);
      expect(pRows.first['is_deleted'], 0);

      // Verify product_addons pivot rows
      final pivotRows = await db.query(
        AppTables.productAddons,
        where: 'product_id = ?',
        whereArgs: [product.id],
      );
      expect(pivotRows.length, 2);
      final storedAddonIds = pivotRows.map((r) => r['addon_id'] as int).toList();
      expect(storedAddonIds, containsAll([addon1Id, addon2Id]));
    });

    test('createProduct throws ValidationException on invalid inputs', () async {
      await expectLater(
        repository.createProduct(
          name: '',
          price: 10000,
          stock: 5,
        ),
        throwsA(isA<ValidationException>()),
      );

      await expectLater(
        repository.createProduct(
          name: 'Valid Name',
          price: 0, // Must be > 0
          stock: 5,
        ),
        throwsA(isA<ValidationException>()),
      );

      await expectLater(
        repository.createProduct(
          name: 'Valid Name',
          price: 10000,
          stock: -1, // Must be >= 0
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('getProducts filters by categoryId and search query', () async {
      final catKopi = await db.insert(AppTables.categories, {'name': 'Kopi'});
      final catTeh = await db.insert(AppTables.categories, {'name': 'Teh'});

      await repository.createProduct(
        name: 'Americano',
        categoryId: catKopi,
        price: 18000,
        stock: 20,
      );
      await repository.createProduct(
        name: 'Cappuccino',
        categoryId: catKopi,
        price: 22000,
        stock: 15,
      );
      await repository.createProduct(
        name: 'Green Tea',
        categoryId: catTeh,
        price: 16000,
        stock: 10,
      );

      // 1. All products
      final all = await repository.getProducts();
      expect(all.length, 3);

      // 2. Filter by category Kopi
      final kopiOnly = await repository.getProducts(categoryId: catKopi);
      expect(kopiOnly.length, 2);
      expect(kopiOnly.map((p) => p.name), containsAll(['Americano', 'Cappuccino']));

      // 3. Search query
      final searchResult = await repository.getProducts(query: 'tea');
      expect(searchResult.length, 1);
      expect(searchResult.first.name, 'Green Tea');
    });

    test('updateProduct updates details, syncs addons, and deletes old photo file when photo is replaced', () async {
      final addon1 = await db.insert(AppTables.addons, {
        'name': 'Gula',
        'price': 1000,
        'stock': 10,
        'is_deleted': 0,
      });
      final addon2 = await db.insert(AppTables.addons, {
        'name': 'Es',
        'price': 1000,
        'stock': 10,
        'is_deleted': 0,
      });

      final created = await repository.createProduct(
        name: 'Kopi Hitam',
        price: 10000,
        stock: 8,
        photoPath: 'product_images/old_photo.jpg',
        addonIds: [addon1],
      );

      // Update with new photo and new addon list
      final updated = await repository.updateProduct(
        id: created.id,
        name: 'Kopi Tubruk Mantap',
        price: 12000,
        stock: 6,
        photoPath: 'product_images/new_photo.jpg',
        addonIds: [addon2],
      );

      expect(updated.name, 'Kopi Tubruk Mantap');
      expect(updated.price, 12000);
      expect(updated.stock, 6);
      expect(updated.photoPath, 'product_images/new_photo.jpg');
      expect(updated.addonIds, [addon2]);

      // Verify that old photo was deleted
      verify(() => mockPhotoStorage.deletePhoto('product_images/old_photo.jpg')).called(1);

      // Verify database pivot table updated
      final pivotRows = await db.query(
        AppTables.productAddons,
        where: 'product_id = ?',
        whereArgs: [created.id],
      );
      expect(pivotRows.length, 1);
      expect(pivotRows.first['addon_id'], addon2);
    });

    test('deleteProduct performs SOFT DELETE and keeps row in database with is_deleted = 1', () async {
      final product = await repository.createProduct(
        name: 'Kopi Kenangan Mantap',
        price: 15000,
        stock: 5,
        photoPath: 'product_images/kenangan.jpg',
      );

      // Perform soft delete
      await repository.deleteProduct(product.id);

      // 1. Normal getProducts should not include soft-deleted product
      final activeProducts = await repository.getProducts();
      expect(activeProducts.any((p) => p.id == product.id), isFalse);

      // 2. Row STILL exists in SQLite products table with is_deleted = 1
      final rows = await db.query(
        AppTables.products,
        where: 'id = ?',
        whereArgs: [product.id],
      );
      expect(rows.length, 1);
      expect(rows.first['is_deleted'], 1);
      expect(rows.first['name'], 'Kopi Kenangan Mantap');
    });

    test('deleting a category sets products.category_id to NULL without crashing or deleting products', () async {
      final catId = await db.insert(AppTables.categories, {'name': 'Kategori Unik'});
      final product = await repository.createProduct(
        name: 'Kue Lapis',
        categoryId: catId,
        price: 8000,
        stock: 10,
      );

      // Delete the category from categories table
      await db.delete(AppTables.categories, where: 'id = ?', whereArgs: [catId]);

      // Product still exists, categoryId is null (ON DELETE SET NULL)
      final reloaded = await repository.getProductById(product.id);
      expect(reloaded, isNotNull);
      expect(reloaded!.name, 'Kue Lapis');
      expect(reloaded.categoryId, isNull);
      expect(reloaded.categoryName, isNull);
    });
  });
}
