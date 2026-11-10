import 'package:sqflite/sqflite.dart' hide Transaction;

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/error/exceptions.dart';
import '../../../cashier/domain/entities/cart_line.dart';
import '../../../cashier/domain/entities/cart_totals.dart';
import '../../domain/entities/checkout_params.dart';
import '../../domain/services/invoice_number_generator.dart';
import '../models/transaction_item_addon_model.dart';
import '../models/transaction_item_model.dart';
import '../models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  Future<TransactionModel> executeCheckout({
    required CheckoutParams params,
    required InvoiceNumberGenerator invoiceGenerator,
  });

  Future<TransactionModel?> getTransactionById(int id);

  Future<TransactionModel?> getTransactionByInvoiceNo(String invoiceNo);

  Future<List<TransactionModel>> getTransactions();
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final AppDatabase _appDatabase;

  TransactionLocalDataSourceImpl(this._appDatabase);

  @override
  Future<TransactionModel> executeCheckout({
    required CheckoutParams params,
    required InvoiceNumberGenerator invoiceGenerator,
  }) async {
    final db = await _appDatabase.database;

    return db.transaction<TransactionModel>((txn) async {
      // 1) Re-validate stock for every product and add-on from current DB rows
      final Map<int, int> productNeeded = {};
      for (final line in params.lines) {
        productNeeded[line.productId] =
            (productNeeded[line.productId] ?? 0) + line.qty;
      }

      final Map<int, int> addonNeeded = {};
      for (final line in params.lines) {
        for (final addon in line.addons) {
          addonNeeded[addon.id] = (addonNeeded[addon.id] ?? 0) + line.qty;
        }
      }

      for (final entry in productNeeded.entries) {
        final productId = entry.key;
        final neededQty = entry.value;

        final pRows = await txn.query(
          AppTables.products,
          columns: ['id', 'name', 'stock', 'is_deleted'],
          where: 'id = ?',
          whereArgs: [productId],
        );

        if (pRows.isEmpty || (pRows.first['is_deleted'] as int) == 1) {
          throw const CheckoutException(
            'Produk tidak ditemukan atau sudah dihapus.',
          );
        }

        final currentStock = pRows.first['stock'] as int;
        final productName = pRows.first['name'] as String;
        if (currentStock < neededQty) {
          throw CheckoutException(
            'Stok produk $productName tidak cukup. Tersisa $currentStock, dibutuhkan $neededQty.',
          );
        }
      }

      for (final entry in addonNeeded.entries) {
        final addonId = entry.key;
        final neededQty = entry.value;

        final aRows = await txn.query(
          AppTables.addons,
          columns: ['id', 'name', 'stock', 'is_deleted'],
          where: 'id = ?',
          whereArgs: [addonId],
        );

        if (aRows.isEmpty || (aRows.first['is_deleted'] as int) == 1) {
          throw const CheckoutException(
            'Add-on tidak ditemukan atau sudah dihapus.',
          );
        }

        final currentStock = aRows.first['stock'] as int;
        final addonName = aRows.first['name'] as String;
        if (currentStock < neededQty) {
          throw CheckoutException(
            'Stok add-on $addonName tidak cukup. Tersisa $currentStock, dibutuhkan $neededQty.',
          );
        }
      }

      // 2) Generate invoice_no
      final time = params.createdAt != null
          ? DateTime.fromMillisecondsSinceEpoch(params.createdAt!)
          : invoiceGenerator.clock.now();
      final prefix = invoiceGenerator.prefixForDate(time);

      final lastTxRows = await txn.query(
        AppTables.transactions,
        columns: ['invoice_no'],
        where: 'invoice_no LIKE ?',
        whereArgs: ['$prefix%'],
        orderBy: 'invoice_no DESC, id DESC',
        limit: 1,
      );

      final lastInvoice = lastTxRows.isNotEmpty
          ? lastTxRows.first['invoice_no'] as String?
          : null;
      final invoiceNo = invoiceGenerator.generate(
        lastInvoiceNo: lastInvoice,
        forTime: time,
      );

      // 3) Insert transactions, transaction_items, transaction_item_addons with snapshot
      var storeName = params.storeName;
      var storeAddress = params.storeAddress;
      var storePhone = params.storePhone;

      if (storeName == null || storeAddress == null || storePhone == null) {
        final storeRows = await txn.query(AppTables.storeProfile, limit: 1);
        if (storeRows.isNotEmpty) {
          storeName ??= storeRows.first['name'] as String?;
          storeAddress ??= storeRows.first['address'] as String?;
          storePhone ??= storeRows.first['phone'] as String?;
        }
      }
      storeName ??= 'Vonte PoS';
      storeAddress ??= '';
      storePhone ??= '';

      final totals = CartTotals.compute(
        lines: params.lines,
        discount: params.discount,
      );
      final subtotal = totals.subtotal;
      final discountAmount = totals.discountAmount;
      final total = totals.total;
      final changeAmount = params.cashReceived - total;
      final createdAt = params.createdAt ?? time.millisecondsSinceEpoch;
      final discountTypeStr =
          params.discount.isNone ? 'none' : params.discount.type.name;

      final txId = await txn.insert(AppTables.transactions, {
        'invoice_no': invoiceNo,
        'cashier_id': params.cashierId,
        'cashier_name': params.cashierName,
        'store_name': storeName,
        'store_address': storeAddress,
        'store_phone': storePhone,
        'subtotal': subtotal,
        'discount_type': discountTypeStr,
        'discount_value': params.discount.value,
        'discount_amount': discountAmount,
        'total': total,
        'cash_received': params.cashReceived,
        'change_amount': changeAmount,
        'created_at': createdAt,
      });

      final List<TransactionItemModel> itemModels = [];
      for (final line in params.lines) {
        final itemId = await txn.insert(AppTables.transactionItems, {
          'transaction_id': txId,
          'product_id': line.productId,
          'product_name': line.productName,
          'unit_price': line.unitPrice,
          'qty': line.qty,
          'line_total': line.unitPrice * line.qty,
        });

        final Map<int, CartAddon> uniqueAddons = {};
        final Map<int, int> addonMultiplier = {};
        for (final a in line.addons) {
          uniqueAddons[a.id] = a;
          addonMultiplier[a.id] = (addonMultiplier[a.id] ?? 0) + 1;
        }

        final List<TransactionItemAddonModel> addonModels = [];
        for (final entry in uniqueAddons.entries) {
          final addon = entry.value;
          final totalAddonQty = line.qty * (addonMultiplier[addon.id] ?? 1);
          final addonLineTotal = addon.price * totalAddonQty;

          final itemAddonId = await txn.insert(
            AppTables.transactionItemAddons,
            {
              'transaction_item_id': itemId,
              'addon_id': addon.id,
              'addon_name': addon.name,
              'addon_price': addon.price,
              'qty': totalAddonQty,
              'line_total': addonLineTotal,
            },
          );

          addonModels.add(TransactionItemAddonModel(
            id: itemAddonId,
            transactionItemId: itemId,
            addonId: addon.id,
            addonName: addon.name,
            addonPrice: addon.price,
            qty: totalAddonQty,
            lineTotal: addonLineTotal,
          ));
        }

        itemModels.add(TransactionItemModel(
          id: itemId,
          transactionId: txId,
          productId: line.productId,
          productName: line.productName,
          unitPrice: line.unitPrice,
          qty: line.qty,
          lineTotal: line.unitPrice * line.qty,
          addons: addonModels,
        ));
      }

      // 4) Deduct stock using atomic CAS query and roll back on 0 affected rows
      for (final entry in productNeeded.entries) {
        final affected = await txn.rawUpdate(
          'UPDATE ${AppTables.products} SET stock = stock - ? WHERE id = ? AND stock >= ?',
          [entry.value, entry.key, entry.value],
        );
        if (affected == 0) {
          throw CheckoutException(
            'Gagal memotong stok produk (ID: ${entry.key}). Stok tidak mencukupi.',
          );
        }
      }

      for (final entry in addonNeeded.entries) {
        final affected = await txn.rawUpdate(
          'UPDATE ${AppTables.addons} SET stock = stock - ? WHERE id = ? AND stock >= ?',
          [entry.value, entry.key, entry.value],
        );
        if (affected == 0) {
          throw CheckoutException(
            'Gagal memotong stok add-on (ID: ${entry.key}). Stok tidak mencukupi.',
          );
        }
      }

      return TransactionModel(
        id: txId,
        invoiceNo: invoiceNo,
        cashierId: params.cashierId,
        cashierName: params.cashierName,
        storeName: storeName,
        storeAddress: storeAddress,
        storePhone: storePhone,
        subtotal: subtotal,
        discountType: discountTypeStr,
        discountValue: params.discount.value,
        discountAmount: discountAmount,
        total: total,
        cashReceived: params.cashReceived,
        changeAmount: changeAmount,
        createdAt: createdAt,
        items: itemModels,
      );
    });
  }

  @override
  Future<TransactionModel?> getTransactionById(int id) async {
    final db = await _appDatabase.database;
    final txRows = await db.query(
      AppTables.transactions,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (txRows.isEmpty) return null;

    final items = await _getItemsForTransaction(db, id);
    return TransactionModel.fromMap(txRows.first, items: items);
  }

  @override
  Future<TransactionModel?> getTransactionByInvoiceNo(String invoiceNo) async {
    final db = await _appDatabase.database;
    final txRows = await db.query(
      AppTables.transactions,
      where: 'invoice_no = ?',
      whereArgs: [invoiceNo],
    );
    if (txRows.isEmpty) return null;

    final id = txRows.first['id'] as int;
    final items = await _getItemsForTransaction(db, id);
    return TransactionModel.fromMap(txRows.first, items: items);
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final db = await _appDatabase.database;
    final txRows = await db.query(
      AppTables.transactions,
      orderBy: 'created_at DESC',
    );

    final List<TransactionModel> results = [];
    for (final row in txRows) {
      final id = row['id'] as int;
      final items = await _getItemsForTransaction(db, id);
      results.add(TransactionModel.fromMap(row, items: items));
    }
    return results;
  }

  Future<List<TransactionItemModel>> _getItemsForTransaction(
    DatabaseExecutor db,
    int transactionId,
  ) async {
    final itemRows = await db.query(
      AppTables.transactionItems,
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
    );

    final List<TransactionItemModel> items = [];
    for (final iRow in itemRows) {
      final itemId = iRow['id'] as int;
      final addonRows = await db.query(
        AppTables.transactionItemAddons,
        where: 'transaction_item_id = ?',
        whereArgs: [itemId],
      );

      final addons = addonRows
          .map((aRow) => TransactionItemAddonModel.fromMap(aRow))
          .toList();

      items.add(TransactionItemModel.fromMap(iRow, addons: addons));
    }
    return items;
  }
}

