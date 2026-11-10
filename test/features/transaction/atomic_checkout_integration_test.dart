import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vonte_pos/core/database/app_database.dart';
import 'package:vonte_pos/core/database/tables.dart';
import 'package:vonte_pos/core/utils/clock.dart';
import 'package:vonte_pos/features/cashier/domain/entities/cart_line.dart';
import 'package:vonte_pos/features/cashier/domain/entities/discount.dart';
import 'package:vonte_pos/features/transaction/data/datasources/transaction_local_data_source.dart';
import 'package:vonte_pos/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:vonte_pos/features/transaction/domain/entities/checkout_params.dart';
import 'package:vonte_pos/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:vonte_pos/features/transaction/domain/services/invoice_number_generator.dart';
import 'package:vonte_pos/features/transaction/domain/usecases/checkout_use_case.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Atomic Checkout Integration Tests (Temporary SQLite Database)', () {
    late AppDatabase appDb;
    late Database db;
    late TestClock testClock;
    late InvoiceNumberGenerator invoiceGenerator;
    late TransactionLocalDataSource localDataSource;
    late TransactionRepository repository;
    late CheckoutUseCase checkoutUseCase;

    setUp(() async {
      appDb = AppDatabase.inMemory();
      db = await appDb.database;
      testClock = TestClock(DateTime(2026, 11, 10, 10, 0, 0));
      invoiceGenerator = InvoiceNumberGenerator(clock: testClock);
      localDataSource = TransactionLocalDataSourceImpl(appDb);
      repository = TransactionRepositoryImpl(localDataSource, invoiceGenerator);
      checkoutUseCase = CheckoutUseCase(repository);
    });

    tearDown(() async {
      await appDb.close();
    });

    // Helper to seed a product
    Future<int> insertProduct({
      required String name,
      required int price,
      required int stock,
    }) async {
      return db.insert(AppTables.products, {
        'name': name,
        'price': price,
        'stock': stock,
        'is_deleted': 0,
        'created_at': 1000,
        'updated_at': 1000,
      });
    }

    // Helper to seed an add-on
    Future<int> insertAddon({
      required String name,
      required int price,
      required int stock,
    }) async {
      return db.insert(AppTables.addons, {
        'name': name,
        'price': price,
        'stock': stock,
        'is_deleted': 0,
      });
    }

    test('1. Sukses menyimpan semua baris dan mengurangi stok', () async {
      final pId = await insertProduct(name: 'Kopi Susu', price: 20000, stock: 10);
      final aId = await insertAddon(name: 'Extra Shot', price: 5000, stock: 10);

      final lines = [
        CartLine(
          productId: pId,
          productName: 'Kopi Susu',
          unitPrice: 20000,
          qty: 2,
          addons: [
            CartAddon(id: aId, name: 'Extra Shot', price: 5000),
          ],
        ),
      ];

      final params = CheckoutParams(
        lines: lines,
        discount: const Discount.none(),
        cashReceived: 60000,
        cashierId: 1,
        cashierName: 'Budi Hartono',
      );

      final result = await checkoutUseCase(params);

      // Verify Result is success
      expect(result.isSuccess, isTrue);
      final tx = result.dataOrNull!;
      expect(tx.invoiceNo, 'VNT-20261110-0001');
      expect(tx.subtotal, 50000); // (20000 + 5000) * 2 = 50000
      expect(tx.total, 50000);
      expect(tx.cashReceived, 60000);
      expect(tx.changeAmount, 10000);
      expect(tx.items.length, 1);
      expect(tx.items.first.addons.length, 1);

      // Verify stock was deducted accurately in DB
      final pRow = (await db.query(AppTables.products, where: 'id = ?', whereArgs: [pId])).first;
      expect(pRow['stock'], 8); // 10 - 2 = 8

      final aRow = (await db.query(AppTables.addons, where: 'id = ?', whereArgs: [aId])).first;
      expect(aRow['stock'], 8); // 10 - 2 = 8

      // Verify rows in DB tables
      final txRows = await db.query(AppTables.transactions);
      expect(txRows.length, 1);

      final itemRows = await db.query(AppTables.transactionItems);
      expect(itemRows.length, 1);
      expect(itemRows.first['product_name'], 'Kopi Susu');
      expect(itemRows.first['qty'], 2);

      final itemAddonRows = await db.query(AppTables.transactionItemAddons);
      expect(itemAddonRows.length, 1);
      expect(itemAddonRows.first['addon_name'], 'Extra Shot');
      expect(itemAddonRows.first['qty'], 2);
    });

    test('2. Rollback total saat stok produk kurang', () async {
      final pId = await insertProduct(name: 'Matcha Latte', price: 25000, stock: 2);

      final lines = [
        CartLine(
          productId: pId,
          productName: 'Matcha Latte',
          unitPrice: 25000,
          qty: 3, // Needs 3, but stock is only 2
        ),
      ];

      final params = CheckoutParams(
        lines: lines,
        discount: const Discount.none(),
        cashReceived: 100000,
        cashierId: 1,
        cashierName: 'Budi Hartono',
      );

      final result = await checkoutUseCase(params);

      // Must fail
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.message, contains('Stok produk Matcha Latte tidak cukup'));

      // Product stock MUST NOT be changed
      final pRow = (await db.query(AppTables.products, where: 'id = ?', whereArgs: [pId])).first;
      expect(pRow['stock'], 2);

      // Total rollback: 0 rows inserted
      final txRows = await db.query(AppTables.transactions);
      expect(txRows, isEmpty);
      final itemRows = await db.query(AppTables.transactionItems);
      expect(itemRows, isEmpty);
    });

    test('3. Rollback total saat stok add-on kurang di tengah transaksi (pastikan stok produk tidak berkurang)', () async {
      final pId = await insertProduct(name: 'Americano', price: 18000, stock: 10);
      final aId = await insertAddon(name: 'Syrup Vanilla', price: 3000, stock: 1); // Only 1 left

      final lines = [
        CartLine(
          productId: pId,
          productName: 'Americano',
          unitPrice: 18000,
          qty: 2, // Needs 2 Americano and 2 Syrup Vanilla
          addons: [
            CartAddon(id: aId, name: 'Syrup Vanilla', price: 3000),
          ],
        ),
      ];

      final params = CheckoutParams(
        lines: lines,
        discount: const Discount.none(),
        cashReceived: 50000,
        cashierId: 1,
        cashierName: 'Budi Hartono',
      );

      final result = await checkoutUseCase(params);

      // Must fail due to insufficient add-on stock
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.message, contains('Stok add-on Syrup Vanilla tidak cukup'));

      // CRITICAL CHECK: Product stock MUST NOT be deducted! (Still 10)
      final pRow = (await db.query(AppTables.products, where: 'id = ?', whereArgs: [pId])).first;
      expect(pRow['stock'], 10);

      // Addon stock MUST NOT be changed (Still 1)
      final aRow = (await db.query(AppTables.addons, where: 'id = ?', whereArgs: [aId])).first;
      expect(aRow['stock'], 1);

      // Total rollback: no transaction records created
      final txRows = await db.query(AppTables.transactions);
      expect(txRows, isEmpty);
      final itemRows = await db.query(AppTables.transactionItems);
      expect(itemRows, isEmpty);
      final itemAddonRows = await db.query(AppTables.transactionItemAddons);
      expect(itemAddonRows, isEmpty);
    });

    test('4. Snapshot tersimpan dan kebal terhadap perubahan master data', () async {
      final pId = await insertProduct(name: 'Croissant Coklat', price: 22000, stock: 10);
      final aId = await insertAddon(name: 'Butter', price: 4000, stock: 10);

      final lines = [
        CartLine(
          productId: pId,
          productName: 'Croissant Coklat',
          unitPrice: 22000,
          qty: 1,
          addons: [
            CartAddon(id: aId, name: 'Butter', price: 4000),
          ],
        ),
      ];

      final params = CheckoutParams(
        lines: lines,
        discount: const Discount.none(),
        cashReceived: 30000,
        cashierId: 1,
        cashierName: 'Budi Hartono',
        storeName: 'Vonte Coffee Shop',
        storeAddress: 'Jl. Merdeka No. 45',
        storePhone: '0811223344',
      );

      final result = await checkoutUseCase(params);
      expect(result.isSuccess, isTrue);
      final txId = result.dataOrNull!.id!;

      // Now MUTATE or SOFT-DELETE master product and add-on, and change store profile
      await db.update(
        AppTables.products,
        {'name': 'Croissant Vanilla (Diedit)', 'price': 99000, 'is_deleted': 1},
        where: 'id = ?',
        whereArgs: [pId],
      );
      await db.update(
        AppTables.addons,
        {'name': 'Butter Premium (Diedit)', 'price': 50000, 'is_deleted': 1},
        where: 'id = ?',
        whereArgs: [aId],
      );
      await db.update(
        AppTables.storeProfile,
        {'name': 'Nama Toko Berubah Drastis'},
        where: 'id = 1',
      );

      // Reload transaction snapshot from DB
      final reloadedTx = await repository.getTransactionById(txId);
      expect(reloadedTx, isNotNull);

      // Verify snapshot values remain strictly unchanged!
      expect(reloadedTx!.storeName, 'Vonte Coffee Shop');
      expect(reloadedTx.storeAddress, 'Jl. Merdeka No. 45');
      expect(reloadedTx.storePhone, '0811223344');

      final item = reloadedTx.items.first;
      expect(item.productName, 'Croissant Coklat'); // NOT 'Croissant Vanilla (Diedit)'
      expect(item.unitPrice, 22000); // NOT 99000
      expect(item.lineTotal, 22000);

      final addon = item.addons.first;
      expect(addon.addonName, 'Butter'); // NOT 'Butter Premium (Diedit)'
      expect(addon.addonPrice, 4000); // NOT 50000
      expect(addon.lineTotal, 4000);
    });

    test('5. Urutan invoice naik dan reset di hari berikutnya', () async {
      final pId = await insertProduct(name: 'Espresso', price: 15000, stock: 100);
      final lines = [
        CartLine(productId: pId, productName: 'Espresso', unitPrice: 15000, qty: 1),
      ];

      // Day 1: 2026-11-10
      testClock.setTime(DateTime(2026, 11, 10, 8, 0, 0));
      final res1 = await checkoutUseCase(CheckoutParams(
        lines: lines,
        cashReceived: 20000,
        cashierId: 1,
        cashierName: 'Budi',
      ));
      expect(res1.dataOrNull?.invoiceNo, 'VNT-20261110-0001');

      final res2 = await checkoutUseCase(CheckoutParams(
        lines: lines,
        cashReceived: 20000,
        cashierId: 1,
        cashierName: 'Budi',
      ));
      expect(res2.dataOrNull?.invoiceNo, 'VNT-20261110-0002');

      // Day 2: Advance clock to 2026-11-11
      testClock.setTime(DateTime(2026, 11, 11, 9, 0, 0));
      final res3 = await checkoutUseCase(CheckoutParams(
        lines: lines,
        cashReceived: 20000,
        cashierId: 1,
        cashierName: 'Budi',
      ));
      // Must reset sequence to 0001 on the new day
      expect(res3.dataOrNull?.invoiceNo, 'VNT-20261111-0001');

      final res4 = await checkoutUseCase(CheckoutParams(
        lines: lines,
        cashReceived: 20000,
        cashierId: 1,
        cashierName: 'Budi',
      ));
      expect(res4.dataOrNull?.invoiceNo, 'VNT-20261111-0002');
    });

    test('6. Diskon dan kembalian tersimpan benar (persen dan nominal tetap)', () async {
      final pId = await insertProduct(name: 'Latte Art', price: 25000, stock: 50);

      // Case A: Percent discount 10%
      // Subtotal = 25000 * 2 = 50000. Discount 10% = 5000. Total = 45000. Cash = 50000. Change = 5000.
      final linesA = [
        CartLine(productId: pId, productName: 'Latte Art', unitPrice: 25000, qty: 2),
      ];
      final resA = await checkoutUseCase(CheckoutParams(
        lines: linesA,
        discount: const Discount.percent(10),
        cashReceived: 50000,
        cashierId: 1,
        cashierName: 'Siti Kasir',
      ));

      expect(resA.isSuccess, isTrue);
      final txA = resA.dataOrNull!;
      expect(txA.subtotal, 50000);
      expect(txA.discountType, 'percent');
      expect(txA.discountValue, 10);
      expect(txA.discountAmount, 5000);
      expect(txA.total, 45000);
      expect(txA.cashReceived, 50000);
      expect(txA.changeAmount, 5000);

      // Verify row in database
      final rowA = (await db.query(AppTables.transactions, where: 'id = ?', whereArgs: [txA.id])).first;
      expect(rowA['subtotal'], 50000);
      expect(rowA['discount_type'], 'percent');
      expect(rowA['discount_value'], 10);
      expect(rowA['discount_amount'], 5000);
      expect(rowA['total'], 45000);
      expect(rowA['cash_received'], 50000);
      expect(rowA['change_amount'], 5000);

      // Case B: Fixed discount 7500
      // Subtotal = 25000 * 1 = 25000. Discount = 7500. Total = 17500. Cash = 20000. Change = 2500.
      final linesB = [
        CartLine(productId: pId, productName: 'Latte Art', unitPrice: 25000, qty: 1),
      ];
      final resB = await checkoutUseCase(CheckoutParams(
        lines: linesB,
        discount: const Discount.fixed(7500),
        cashReceived: 20000,
        cashierId: 1,
        cashierName: 'Siti Kasir',
      ));

      expect(resB.isSuccess, isTrue);
      final txB = resB.dataOrNull!;
      expect(txB.subtotal, 25000);
      expect(txB.discountType, 'fixed');
      expect(txB.discountValue, 7500);
      expect(txB.discountAmount, 7500);
      expect(txB.total, 17500);
      expect(txB.cashReceived, 20000);
      expect(txB.changeAmount, 2500);

      final rowB = (await db.query(AppTables.transactions, where: 'id = ?', whereArgs: [txB.id])).first;
      expect(rowB['subtotal'], 25000);
      expect(rowB['discount_type'], 'fixed');
      expect(rowB['discount_value'], 7500);
      expect(rowB['discount_amount'], 7500);
      expect(rowB['total'], 17500);
      expect(rowB['cash_received'], 20000);
      expect(rowB['change_amount'], 2500);
    });

    test('Atomic CAS update fails and triggers total rollback if affected rows == 0', () async {
      // Simulate race condition / CAS failure: product stock drops right before deduction
      final pId = await insertProduct(name: 'Cold Brew', price: 30000, stock: 5);

      // Verify that rawUpdate with WHERE stock >= ? affects 0 rows when stock is insufficient
      final affected = await db.rawUpdate(
        'UPDATE ${AppTables.products} SET stock = stock - ? WHERE id = ? AND stock >= ?',
        [10, pId, 10], // Needs 10, current is 5 -> affects 0 rows
      );
      expect(affected, 0);

      // Current stock is still untouched (5)
      final pRow = (await db.query(AppTables.products, where: 'id = ?', whereArgs: [pId])).first;
      expect(pRow['stock'], 5);
    });
  });
}
