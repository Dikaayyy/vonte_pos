import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:vonte_pos/core/database/app_database.dart';
import 'package:vonte_pos/core/database/tables.dart';
import 'package:vonte_pos/core/utils/clock.dart';
import 'package:vonte_pos/features/cashier/domain/entities/cart_line.dart';
import 'package:vonte_pos/features/cashier/domain/entities/discount.dart';
import 'package:vonte_pos/features/transaction/data/datasources/transaction_local_data_source.dart';
import 'package:vonte_pos/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:vonte_pos/features/transaction/domain/entities/checkout_params.dart';
import 'package:vonte_pos/features/transaction/domain/entities/transaction.dart';
import 'package:vonte_pos/features/transaction/domain/entities/transaction_item.dart';
import 'package:vonte_pos/features/transaction/domain/entities/transaction_item_addon.dart';
import 'package:vonte_pos/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:vonte_pos/features/transaction/domain/services/invoice_number_generator.dart';
import 'package:vonte_pos/features/transaction/domain/usecases/checkout_use_case.dart';
import 'package:vonte_pos/features/transaction/domain/usecases/get_report_use_case.dart';
import 'package:vonte_pos/features/transaction/presentation/widgets/receipt_view.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Hard Rule 2: Transaction History & Report Immutability Tests', () {
    late AppDatabase appDb;
    late Database db;
    late TestClock testClock;
    late InvoiceNumberGenerator invoiceGenerator;
    late TransactionLocalDataSource localDataSource;
    late TransactionRepository repository;
    late CheckoutUseCase checkoutUseCase;
    late GetReportUseCase getReportUseCase;

    setUp(() async {
      appDb = AppDatabase.inMemory();
      db = await appDb.database;
      testClock = TestClock(DateTime(2026, 11, 10, 14, 30, 0));
      invoiceGenerator = InvoiceNumberGenerator(clock: testClock);
      localDataSource = TransactionLocalDataSourceImpl(appDb);
      repository = TransactionRepositoryImpl(localDataSource, invoiceGenerator);
      checkoutUseCase = CheckoutUseCase(repository);
      getReportUseCase = GetReportUseCase(repository);
    });

    tearDown(() async {
      await appDb.close();
    });

    test('1. Laporan saat belum ada transaksi mengembalikan nilai 0 dan list kosong tanpa error', () async {
      // Pastikan tabel transaksi masih kosong
      final initialRows = await db.query(AppTables.transactions);
      expect(initialRows, isEmpty);

      // Muat laporan melalui use case
      final report = await getReportUseCase();

      expect(report.totalRevenue, equals(0));
      expect(report.transactionCount, equals(0));
      expect(report.transactions, isEmpty);

      // Verifikasi query transactions langsung
      final transactions = await repository.getTransactions();
      expect(transactions, isEmpty);
    });

    test(
      '2. Immutability: jual produk -> ubah harga produk -> soft-delete produk -> muat ulang struk dan laporan -> nama, harga, dan total tidak berubah, bebas null dan error',
      () async {
        // Step A: Seed profil toko, produk, dan add-on ke master data
        await db.update(
          AppTables.storeProfile,
          {
            'name': 'Kedai Kopi Vonte',
            'address': 'Jl. Braga No. 12, Bandung',
            'phone': '081234567890',
            'receipt_footer': 'Terima kasih atas kunjungan Anda',
          },
          where: 'id = ?',
          whereArgs: [1],
        );

        final productId = await db.insert(AppTables.products, {
          'name': 'Es Kopi Susu Aren',
          'price': 18000,
          'stock': 20,
          'is_deleted': 0,
          'created_at': 1000,
          'updated_at': 1000,
        });

        final addonId = await db.insert(AppTables.addons, {
          'name': 'Double Shot Espresso',
          'price': 5000,
          'stock': 20,
          'is_deleted': 0,
        });

        // Step B: Jual produk (Checkout)
        // 2x Es Kopi Susu Aren (18.000) + 1x Double Shot Espresso (5.000)
        // Subtotal = (18.000 + 5.000) * 2 = 46.000
        // Uang diterima: 50.000 -> Kembalian: 4.000
        final cartLines = [
          CartLine(
            productId: productId,
            productName: 'Es Kopi Susu Aren',
            unitPrice: 18000,
            qty: 2,
            addons: [
              CartAddon(id: addonId, name: 'Double Shot Espresso', price: 5000),
            ],
          ),
        ];

        final checkoutParams = CheckoutParams(
          lines: cartLines,
          discount: const Discount.none(),
          cashReceived: 50000,
          cashierId: 1,
          cashierName: 'Ahmad Kasir',
          createdAt: DateTime(2026, 11, 10, 14, 30, 0).millisecondsSinceEpoch,
        );

        final checkoutResult = await checkoutUseCase(checkoutParams);
        expect(checkoutResult.isSuccess, isTrue);

        final originalTransaction = checkoutResult.dataOrNull!;
        expect(originalTransaction.total, equals(46000));
        expect(originalTransaction.subtotal, equals(46000));
        expect(originalTransaction.cashReceived, equals(50000));
        expect(originalTransaction.changeAmount, equals(4000));
        expect(originalTransaction.invoiceNo, equals('VNT-20261110-0001'));

        // Step C: Ubah master data produk dan add-on (ganti nama & naikkan harga)
        await db.update(
          AppTables.products,
          {
            'name': 'Es Kopi Susu Mewah V2',
            'price': 45000, // Harga naik drastis dari 18.000 -> 45.000
            'updated_at': 5000,
          },
          where: 'id = ?',
          whereArgs: [productId],
        );

        await db.update(
          AppTables.addons,
          {
            'name': 'Triple Shot Gold',
            'price': 15000, // Harga naik drastis dari 5.000 -> 15.000
          },
          where: 'id = ?',
          whereArgs: [addonId],
        );

        // Step D: Soft-delete produk dan add-on dari katalog toko (is_deleted = 1)
        await db.update(
          AppTables.products,
          {'is_deleted': 1},
          where: 'id = ?',
          whereArgs: [productId],
        );

        await db.update(
          AppTables.addons,
          {'is_deleted': 1},
          where: 'id = ?',
          whereArgs: [addonId],
        );

        // Verifikasi bahwa di tabel master statusnya benar-benar is_deleted = 1
        final productInDb = await db.query(
          AppTables.products,
          where: 'id = ?',
          whereArgs: [productId],
        );
        expect(productInDb.first['is_deleted'], equals(1));
        expect(productInDb.first['price'], equals(45000));

        // Step E: Muat ulang struk dan laporan dari database
        final reloadedTransaction = await repository.getTransactionById(
          originalTransaction.id!,
        );
        expect(reloadedTransaction, isNotNull);

        final report = await getReportUseCase();

        // Step F: Assertions - Pastikan data laporan tidak berubah
        expect(report.transactionCount, equals(1));
        // Total pendapatan tetap 46.000 (TIDAK terpengaruh harga baru 45.000 ataupun soft-delete)
        expect(report.totalRevenue, equals(46000));
        expect(report.transactions.length, equals(1));

        final reportTx = report.transactions.first;
        expect(reportTx.invoiceNo, equals('VNT-20261110-0001'));
        expect(reportTx.total, equals(46000));
        expect(reportTx.subtotal, equals(46000));
        expect(reportTx.cashierName, equals('Ahmad Kasir'));
        expect(reportTx.storeName, equals('Kedai Kopi Vonte'));

        // Step G: Assertions - Pastikan data struk snapshot tidak berubah dan tidak ada null/error
        expect(reloadedTransaction!.total, equals(46000));
        expect(reloadedTransaction.subtotal, equals(46000));
        expect(reloadedTransaction.cashReceived, equals(50000));
        expect(reloadedTransaction.changeAmount, equals(4000));
        expect(reloadedTransaction.items.length, equals(1));

        final item = reloadedTransaction.items.first;
        // Nama produk tetap nama lama saat transaksi dibuat
        expect(item.productName, equals('Es Kopi Susu Aren'));
        // Harga satuan tetap harga lama
        expect(item.unitPrice, equals(18000));
        expect(item.qty, equals(2));
        expect(item.lineTotal, equals(36000));

        // Addon tetap snapshot lama
        expect(item.addons.length, equals(1));
        final addon = item.addons.first;
        expect(addon.addonName, equals('Double Shot Espresso'));
        expect(addon.addonPrice, equals(5000));
        expect(addon.qty, equals(2));
        expect(addon.lineTotal, equals(10000));
      },
    );

    testWidgets(
      '3. Struk dapat dirender sempurna dari snapshot transaksi yang produknya sudah dihapus',
      (tester) async {
        // Buat transaksi dengan produk yang sudah dihapus
        final deletedProductTx = const Transaction(
          id: 99,
          invoiceNo: 'VNT-20261110-0099',
          cashierId: 1,
          cashierName: 'Ahmad Kasir',
          storeName: 'Kedai Kopi Vonte',
          storeAddress: 'Jl. Braga No. 12',
          storePhone: '081234567890',
          subtotal: 46000,
          discountType: 'none',
          discountValue: 0,
          discountAmount: 0,
          total: 46000,
          cashReceived: 50000,
          changeAmount: 4000,
          createdAt: 1762759800000,
          items: [
            TransactionItem(
              id: 1,
              transactionId: 99,
              productId: 999, // Produk sudah terhapus di master
              productName: 'Es Kopi Susu Aren',
              unitPrice: 18000,
              qty: 2,
              lineTotal: 36000,
              addons: [
                TransactionItemAddon(
                  id: 1,
                  transactionItemId: 1,
                  addonId: 888, // Addon sudah terhapus di master
                  addonName: 'Double Shot Espresso',
                  addonPrice: 5000,
                  qty: 2,
                  lineTotal: 10000,
                ),
              ],
            ),
          ],
        );

        // Render widget ReceiptView
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ReceiptView(transaction: deletedProductTx),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verifikasi semua teks snapshot tampil tanpa error
        expect(find.text('Kedai Kopi Vonte'), findsOneWidget);
        expect(find.text('VNT-20261110-0099'), findsOneWidget);
        expect(find.text('Es Kopi Susu Aren'), findsOneWidget);
        expect(find.textContaining('Double Shot Espresso'), findsOneWidget);
        expect(find.text('Ahmad Kasir'), findsOneWidget);
        expect(find.text('Rp46.000'), findsWidgets);
      },
    );
  });
}
