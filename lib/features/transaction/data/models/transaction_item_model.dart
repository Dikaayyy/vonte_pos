import '../../domain/entities/transaction_item.dart';
import 'transaction_item_addon_model.dart';

class TransactionItemModel extends TransactionItem {
  const TransactionItemModel({
    super.id,
    super.transactionId,
    required super.productId,
    required super.productName,
    required super.unitPrice,
    required super.qty,
    required super.lineTotal,
    super.addons = const [],
  });

  factory TransactionItemModel.fromMap(
    Map<String, dynamic> map, {
    List<TransactionItemAddonModel> addons = const [],
  }) {
    return TransactionItemModel(
      id: map['id'] as int?,
      transactionId: map['transaction_id'] as int?,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String,
      unitPrice: map['unit_price'] as int,
      qty: map['qty'] as int,
      lineTotal: map['line_total'] as int,
      addons: addons,
    );
  }

  factory TransactionItemModel.fromEntity(TransactionItem entity) {
    return TransactionItemModel(
      id: entity.id,
      transactionId: entity.transactionId,
      productId: entity.productId,
      productName: entity.productName,
      unitPrice: entity.unitPrice,
      qty: entity.qty,
      lineTotal: entity.lineTotal,
      addons: entity.addons,
    );
  }

  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = <String, dynamic>{
      'transaction_id': transactionId,
      'product_id': productId,
      'product_name': productName,
      'unit_price': unitPrice,
      'qty': qty,
      'line_total': lineTotal,
    };
    if (includeId && id != null) {
      map['id'] = id;
    }
    return map;
  }

  TransactionItem toEntity() {
    return TransactionItem(
      id: id,
      transactionId: transactionId,
      productId: productId,
      productName: productName,
      unitPrice: unitPrice,
      qty: qty,
      lineTotal: lineTotal,
      addons: addons.map((a) {
        if (a is TransactionItemAddonModel) {
          return a.toEntity();
        }
        return a;
      }).toList(),
    );
  }
}

