import 'package:equatable/equatable.dart';

import 'transaction_item_addon.dart';

/// Snapshot entity for an item line in a transaction.
class TransactionItem extends Equatable {
  final int? id;
  final int? transactionId;
  final int productId;
  final String productName;
  final int unitPrice;
  final int qty;
  final int lineTotal;
  final List<TransactionItemAddon> addons;

  const TransactionItem({
    this.id,
    this.transactionId,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.qty,
    required this.lineTotal,
    this.addons = const [],
  });

  TransactionItem copyWith({
    int? id,
    int? transactionId,
    int? productId,
    String? productName,
    int? unitPrice,
    int? qty,
    int? lineTotal,
    List<TransactionItemAddon>? addons,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      qty: qty ?? this.qty,
      lineTotal: lineTotal ?? this.lineTotal,
      addons: addons ?? this.addons,
    );
  }

  @override
  List<Object?> get props => [
        id,
        transactionId,
        productId,
        productName,
        unitPrice,
        qty,
        lineTotal,
        addons,
      ];
}

