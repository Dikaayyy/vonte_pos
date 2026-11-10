import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vonte_pos/core/database/app_database.dart';
import 'package:vonte_pos/core/database/tables.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('AppDatabase Foundation', () {
    late AppDatabase appDb;
    late Database db;

    setUp(() async {
      appDb = AppDatabase.inMemory();
      db = await appDb.database;
    });

    tearDown(() async {
      await appDb.close();
    });

    test('PRAGMA foreign_keys is enabled', () async {
      final result = await db.rawQuery('PRAGMA foreign_keys');
      expect(result.first['foreign_keys'], equals(1));
    });

    test('creates all v1 schema tables', () async {
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
      );
      final tableNames = tables.map((row) => row['name'] as String).toSet();

      final expectedTables = {
        AppTables.users,
        AppTables.sessions,
        AppTables.storeProfile,
        AppTables.categories,
        AppTables.products,
        AppTables.addons,
        AppTables.productAddons,
        AppTables.transactions,
        AppTables.transactionItems,
        AppTables.transactionItemAddons,
      };

      expect(tableNames, containsAll(expectedTables));
    });

    test('creates expected sensible indexes', () async {
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'index' AND name NOT LIKE 'sqlite_%'",
      );
      final indexNames = indexes.map((row) => row['name'] as String).toSet();

      final expectedIndexes = {
        'idx_sessions_user_id',
        'idx_products_category_id',
        'idx_products_name',
        'idx_products_is_deleted',
        'idx_addons_is_deleted',
        'idx_product_addons_addon_id',
        'idx_transactions_created_at',
        'idx_transaction_items_transaction_id',
        'idx_transaction_item_addons_item_id',
      };

      expect(indexNames, containsAll(expectedIndexes));
    });

    test('seeds one neutral default store_profile row', () async {
      final profiles = await db.query(AppTables.storeProfile);
      expect(profiles.length, equals(1));

      final profile = profiles.first;
      expect(profile['id'], equals(1));
      expect(profile['name'], equals('Vonte PoS'));
      expect(profile['address'], isNotEmpty);
      expect(profile['phone'], isNotEmpty);
      expect(profile['receipt_footer'], isNotEmpty);
    });

    group('Foreign Key Enforcement', () {
      test('fails when inserting session with invalid user_id', () async {
        expect(
          () => db.insert(AppTables.sessions, {
            'user_id': 99999,
            'logged_in_at': DateTime.now().millisecondsSinceEpoch,
          }),
          throwsA(isA<DatabaseException>()),
        );
      });

      test('fails when inserting product with invalid category_id', () async {
        expect(
          () => db.insert(AppTables.products, {
            'category_id': 99999,
            'name': 'Kopi Susu',
            'price': 18000,
            'stock': 10,
            'created_at': 1000,
            'updated_at': 1000,
          }),
          throwsA(isA<DatabaseException>()),
        );
      });

      test('fails when inserting product_addons with invalid product_id', () async {
        final addonId = await db.insert(AppTables.addons, {
          'name': 'Extra Shot',
          'price': 5000,
          'stock': 20,
        });

        expect(
          () => db.insert(AppTables.productAddons, {
            'product_id': 99999,
            'addon_id': addonId,
          }),
          throwsA(isA<DatabaseException>()),
        );
      });

      test('fails when inserting product_addons with invalid addon_id', () async {
        final productId = await db.insert(AppTables.products, {
          'name': 'Americano',
          'price': 15000,
          'stock': 10,
          'created_at': 1000,
          'updated_at': 1000,
        });

        expect(
          () => db.insert(AppTables.productAddons, {
            'product_id': productId,
            'addon_id': 99999,
          }),
          throwsA(isA<DatabaseException>()),
        );
      });

      test('fails when inserting transaction_item with invalid transaction_id', () async {
        expect(
          () => db.insert(AppTables.transactionItems, {
            'transaction_id': 99999,
            'product_id': 1,
            'product_name': 'Kopi',
            'unit_price': 15000,
            'qty': 1,
            'line_total': 15000,
          }),
          throwsA(isA<DatabaseException>()),
        );
      });

      test('fails when inserting transaction_item_addon with invalid transaction_item_id', () async {
        expect(
          () => db.insert(AppTables.transactionItemAddons, {
            'transaction_item_id': 99999,
            'addon_id': 1,
            'addon_name': 'Extra Shot',
            'addon_price': 5000,
            'qty': 1,
            'line_total': 5000,
          }),
          throwsA(isA<DatabaseException>()),
        );
      });

      test('allows product_id and addon_id in transaction tables to be reference-only', () async {
        // Transactions and items store snapshots; product_id and addon_id are reference-only
        final txId = await db.insert(AppTables.transactions, {
          'invoice_no': 'VNT-20261110-0001',
          'cashier_id': 1,
          'cashier_name': 'Budi',
          'store_name': 'Vonte PoS',
          'store_address': 'Jl. Bisnis No. 1',
          'store_phone': '081234567890',
          'subtotal': 20000,
          'discount_type': 'none',
          'discount_value': 0,
          'discount_amount': 0,
          'total': 20000,
          'cash_received': 20000,
          'change_amount': 0,
          'created_at': 1000,
        });

        final itemId = await db.insert(AppTables.transactionItems, {
          'transaction_id': txId,
          'product_id': 88888, // Does not exist in products, allowed as snapshot
          'product_name': 'Kopi Mantap',
          'unit_price': 20000,
          'qty': 1,
          'line_total': 20000,
        });

        final itemAddonId = await db.insert(AppTables.transactionItemAddons, {
          'transaction_item_id': itemId,
          'addon_id': 77777, // Does not exist in addons, allowed as snapshot
          'addon_name': 'Extra Gula',
          'addon_price': 2000,
          'qty': 1,
          'line_total': 2000,
        });

        expect(itemId, isPositive);
        expect(itemAddonId, isPositive);
      });

      test('cascades deletion from users to sessions', () async {
        final userId = await db.insert(AppTables.users, {
          'name': 'Kasir Satu',
          'username': 'kasir1',
          'password_hash': 'hash123',
          'salt': 'salt123',
          'created_at': 1000,
        });

        await db.insert(AppTables.sessions, {
          'user_id': userId,
          'logged_in_at': 1000,
        });

        expect(
          (await db.query(AppTables.sessions, where: 'user_id = ?', whereArgs: [userId])).length,
          equals(1),
        );

        await db.delete(AppTables.users, where: 'id = ?', whereArgs: [userId]);

        expect(
          (await db.query(AppTables.sessions, where: 'user_id = ?', whereArgs: [userId])).length,
          equals(0),
        );
      });

      test('sets products.category_id to NULL when category is deleted', () async {
        final catId = await db.insert(AppTables.categories, {
          'name': 'Kopi',
        });

        final prodId = await db.insert(AppTables.products, {
          'category_id': catId,
          'name': 'Latte',
          'price': 22000,
          'stock': 15,
          'created_at': 1000,
          'updated_at': 1000,
        });

        await db.delete(AppTables.categories, where: 'id = ?', whereArgs: [catId]);

        final updated = await db.query(AppTables.products, where: 'id = ?', whereArgs: [prodId]);
        expect(updated.first['category_id'], isNull);
        expect(updated.first['name'], equals('Latte'));
      });

      test('cascades deletion from products and addons to product_addons', () async {
        final prodId = await db.insert(AppTables.products, {
          'name': 'Espresso',
          'price': 12000,
          'stock': 20,
          'created_at': 1000,
          'updated_at': 1000,
        });

        final addonId = await db.insert(AppTables.addons, {
          'name': 'Caramel Syrup',
          'price': 4000,
          'stock': 30,
        });

        await db.insert(AppTables.productAddons, {
          'product_id': prodId,
          'addon_id': addonId,
        });

        expect(
          (await db.query(AppTables.productAddons, where: 'product_id = ?', whereArgs: [prodId])).length,
          equals(1),
        );

        // Delete product
        await db.delete(AppTables.products, where: 'id = ?', whereArgs: [prodId]);
        expect(
          (await db.query(AppTables.productAddons, where: 'product_id = ?', whereArgs: [prodId])).length,
          equals(0),
        );
      });

      test('cascades deletion from transactions to transaction_items and addons', () async {
        final txId = await db.insert(AppTables.transactions, {
          'invoice_no': 'VNT-20261110-0002',
          'cashier_id': 1,
          'cashier_name': 'Kasir',
          'store_name': 'Vonte PoS',
          'store_address': 'Jl. Bisnis No. 1',
          'store_phone': '081234567890',
          'subtotal': 15000,
          'discount_type': 'none',
          'discount_value': 0,
          'discount_amount': 0,
          'total': 15000,
          'cash_received': 20000,
          'change_amount': 5000,
          'created_at': 1000,
        });

        final itemId = await db.insert(AppTables.transactionItems, {
          'transaction_id': txId,
          'product_id': 1,
          'product_name': 'Kopi Hitam',
          'unit_price': 15000,
          'qty': 1,
          'line_total': 15000,
        });

        await db.insert(AppTables.transactionItemAddons, {
          'transaction_item_id': itemId,
          'addon_id': 1,
          'addon_name': 'Extra Shot',
          'addon_price': 5000,
          'qty': 1,
          'line_total': 5000,
        });

        await db.delete(AppTables.transactions, where: 'id = ?', whereArgs: [txId]);

        expect(
          (await db.query(AppTables.transactionItems, where: 'transaction_id = ?', whereArgs: [txId])).length,
          equals(0),
        );
        expect(
          (await db.query(AppTables.transactionItemAddons, where: 'transaction_item_id = ?', whereArgs: [itemId])).length,
          equals(0),
        );
      });
    });

    group('UNIQUE Constraints', () {
      test('enforces UNIQUE on users.username', () async {
        await db.insert(AppTables.users, {
          'name': 'User Satu',
          'username': 'admin',
          'password_hash': 'h1',
          'salt': 's1',
          'created_at': 1000,
        });

        expect(
          () => db.insert(AppTables.users, {
            'name': 'User Dua',
            'username': 'admin',
            'password_hash': 'h2',
            'salt': 's2',
            'created_at': 2000,
          }),
          throwsA(isA<DatabaseException>()),
        );
      });

      test('enforces UNIQUE on categories.name', () async {
        await db.insert(AppTables.categories, {
          'name': 'Makanan',
        });

        expect(
          () => db.insert(AppTables.categories, {
            'name': 'Makanan',
          }),
          throwsA(isA<DatabaseException>()),
        );
      });

      test('enforces UNIQUE on transactions.invoice_no', () async {
        await db.insert(AppTables.transactions, {
          'invoice_no': 'VNT-20261110-0099',
          'cashier_id': 1,
          'cashier_name': 'Kasir',
          'store_name': 'Vonte PoS',
          'store_address': 'Jl. Bisnis No. 1',
          'store_phone': '081234567890',
          'subtotal': 10000,
          'discount_type': 'none',
          'discount_value': 0,
          'discount_amount': 0,
          'total': 10000,
          'cash_received': 10000,
          'change_amount': 0,
          'created_at': 1000,
        });

        expect(
          () => db.insert(AppTables.transactions, {
            'invoice_no': 'VNT-20261110-0099',
            'cashier_id': 2,
            'cashier_name': 'Kasir 2',
            'store_name': 'Vonte PoS',
            'store_address': 'Jl. Bisnis No. 1',
            'store_phone': '081234567890',
            'subtotal': 15000,
            'discount_type': 'none',
            'discount_value': 0,
            'discount_amount': 0,
            'total': 15000,
            'cash_received': 20000,
            'change_amount': 5000,
            'created_at': 2000,
          }),
          throwsA(isA<DatabaseException>()),
        );
      });

      test('enforces composite primary key on product_addons', () async {
        final prodId = await db.insert(AppTables.products, {
          'name': 'Tea',
          'price': 10000,
          'stock': 20,
          'created_at': 1000,
          'updated_at': 1000,
        });

        final addonId = await db.insert(AppTables.addons, {
          'name': 'Sugar',
          'price': 1000,
          'stock': 50,
        });

        await db.insert(AppTables.productAddons, {
          'product_id': prodId,
          'addon_id': addonId,
        });

        expect(
          () => db.insert(AppTables.productAddons, {
            'product_id': prodId,
            'addon_id': addonId,
          }),
          throwsA(isA<DatabaseException>()),
        );
      });
    });
  });
}

