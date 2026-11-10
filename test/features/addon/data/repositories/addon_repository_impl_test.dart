import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/core/database/app_database.dart';
import 'package:vonte_pos/core/database/tables.dart';
import 'package:vonte_pos/core/error/exceptions.dart';
import 'package:vonte_pos/features/addon/data/datasources/addon_local_data_source.dart';
import 'package:vonte_pos/features/addon/data/repositories/addon_repository_impl.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('AddonRepositoryImpl with In-Memory SQLite Database', () {
    late AppDatabase appDb;
    late Database db;
    late AddonLocalDataSource dataSource;
    late AddonRepositoryImpl repository;

    setUp(() async {
      appDb = AppDatabase.inMemory();
      db = await appDb.database;
      dataSource = AddonLocalDataSourceImpl(appDb);
      repository = AddonRepositoryImpl(dataSource);
    });

    tearDown(() async {
      await appDb.close();
    });

    test('createAddon stores valid addon in database with is_deleted = 0', () async {
      final addon = await repository.createAddon(
        name: '  Extra Shot  ',
        price: 4000,
        stock: 15,
      );

      expect(addon.id, greaterThan(0));
      expect(addon.name, equals('Extra Shot'));
      expect(addon.price, equals(4000));
      expect(addon.stock, equals(15));
      expect(addon.isDeleted, isFalse);

      final rows = await db.query(
        AppTables.addons,
        where: 'id = ?',
        whereArgs: [addon.id],
      );
      expect(rows.length, equals(1));
      expect(rows.first['name'], equals('Extra Shot'));
      expect(rows.first['price'], equals(4000));
      expect(rows.first['stock'], equals(15));
      expect(rows.first['is_deleted'], equals(0));
    });

    test('createAddon allows 0 price and 0 stock', () async {
      final freeAddon = await repository.createAddon(
        name: 'Less Sugar',
        price: 0,
        stock: 0,
      );

      expect(freeAddon.price, equals(0));
      expect(freeAddon.stock, equals(0));
      expect(freeAddon.isOutOfStock, isTrue);
    });

    test('createAddon throws ValidationException on invalid input', () async {
      // Empty name
      expect(
        () => repository.createAddon(name: '   ', price: 1000, stock: 5),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            AppStrings.addonNameRequired,
          ),
        ),
      );

      // Negative price
      expect(
        () => repository.createAddon(name: 'Syrup', price: -500, stock: 5),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            AppStrings.addonPriceInvalid,
          ),
        ),
      );

      // Negative stock
      expect(
        () => repository.createAddon(name: 'Syrup', price: 1000, stock: -1),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            AppStrings.addonStockInvalid,
          ),
        ),
      );
    });

    test('updateAddon updates existing addon data', () async {
      final created = await repository.createAddon(
        name: 'Grass Jelly',
        price: 3000,
        stock: 8,
      );

      final updated = await repository.updateAddon(
        id: created.id,
        name: 'Grass Jelly Special',
        price: 3500,
        stock: 12,
      );

      expect(updated.name, equals('Grass Jelly Special'));
      expect(updated.price, equals(3500));
      expect(updated.stock, equals(12));

      final rows = await db.query(
        AppTables.addons,
        where: 'id = ?',
        whereArgs: [created.id],
      );
      expect(rows.first['name'], equals('Grass Jelly Special'));
      expect(rows.first['price'], equals(3500));
      expect(rows.first['stock'], equals(12));
    });

    test(
        'Hapus memakai soft delete: is_deleted = 1, tidak muncul di daftar, tetapi barisnya tetap ada di SQLite',
        () async {
      // 1. Create two addons
      final addon1 = await repository.createAddon(
        name: 'Extra Shot Espresso',
        price: 4000,
        stock: 10,
      );
      final addon2 = await repository.createAddon(
        name: 'Oat Milk Sub',
        price: 6000,
        stock: 5,
      );

      // Verify both appear in getAddons()
      final initialList = await repository.getAddons();
      expect(initialList.length, equals(2));
      expect(initialList.map((a) => a.id), containsAll([addon1.id, addon2.id]));

      // 2. Soft-delete addon1
      await repository.deleteAddon(addon1.id);

      // 3. Verify getAddons() omits addon1 and only returns addon2
      final afterDeleteList = await repository.getAddons();
      expect(afterDeleteList.length, equals(1));
      expect(afterDeleteList.first.id, equals(addon2.id));
      expect(afterDeleteList.first.name, equals('Oat Milk Sub'));
      expect(afterDeleteList.any((a) => a.id == addon1.id), isFalse);

      // 4. Verify raw database table: the row STILL EXISTS with is_deleted = 1
      final rawRows = await db.rawQuery(
        'SELECT id, name, price, stock, is_deleted FROM ${AppTables.addons} WHERE id = ?',
        [addon1.id],
      );
      expect(rawRows.length, equals(1),
          reason: 'Baris add-on yang dihapus harus tetap ada di tabel.');
      expect(rawRows.first['id'], equals(addon1.id));
      expect(rawRows.first['name'], equals('Extra Shot Espresso'));
      expect(rawRows.first['price'], equals(4000));
      expect(rawRows.first['stock'], equals(10));
      expect(rawRows.first['is_deleted'], equals(1),
          reason: 'Kolom is_deleted harus bernilai 1 setelah soft delete.');

      // 5. Query with includeDeleted: true includes the soft-deleted row
      final allWithDeleted = await repository.getAddons(includeDeleted: true);
      expect(allWithDeleted.length, equals(2));
      final deletedItem = allWithDeleted.firstWhere((a) => a.id == addon1.id);
      expect(deletedItem.isDeleted, isTrue);
    });

    test('deleteAddon throws AppDatabaseException when addon does not exist or already deleted', () async {
      expect(
        () => repository.deleteAddon(999),
        throwsA(isA<AppDatabaseException>()),
      );

      final addon = await repository.createAddon(
        name: 'Bobba',
        price: 3000,
        stock: 5,
      );
      await repository.deleteAddon(addon.id);

      // Trying to delete again fails because is_deleted = 0 condition doesn't match
      expect(
        () => repository.deleteAddon(addon.id),
        throwsA(isA<AppDatabaseException>()),
      );
    });

    test('updateAddon throws AppDatabaseException when updating soft-deleted addon', () async {
      final addon = await repository.createAddon(
        name: 'Pudding',
        price: 2500,
        stock: 5,
      );
      await repository.deleteAddon(addon.id);

      expect(
        () => repository.updateAddon(
          id: addon.id,
          name: 'Pudding Baru',
          price: 3000,
          stock: 10,
        ),
        throwsA(isA<AppDatabaseException>()),
      );
    });
  });
}

