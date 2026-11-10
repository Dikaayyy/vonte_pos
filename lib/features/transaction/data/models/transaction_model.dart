import '../../domain/entities/transaction.dart';
import 'transaction_item_model.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    super.id,
    required super.invoiceNo,
    required super.cashierId,
    required super.cashierName,
    required super.storeName,
    required super.storeAddress,
    required super.storePhone,
    required super.subtotal,
    required super.discountType,
    required super.discountValue,
    required super.discountAmount,
    required super.total,
    required super.cashReceived,
    required super.changeAmount,
    required super.createdAt,
    super.items = const [],
  });

  factory TransactionModel.fromMap(
    Map<String, dynamic> map, {
    List<TransactionItemModel> items = const [],
  }) {
    return TransactionModel(
      id: map['id'] as int?,
      invoiceNo: map['invoice_no'] as String,
      cashierId: map['cashier_id'] as int,
      cashierName: map['cashier_name'] as String,
      storeName: map['store_name'] as String,
      storeAddress: map['store_address'] as String,
      storePhone: map['store_phone'] as String,
      subtotal: map['subtotal'] as int,
      discountType: map['discount_type'] as String,
      discountValue: map['discount_value'] as int,
      discountAmount: map['discount_amount'] as int,
      total: map['total'] as int,
      cashReceived: map['cash_received'] as int,
      changeAmount: map['change_amount'] as int,
      createdAt: map['created_at'] as int,
      items: items,
    );
  }

  factory TransactionModel.fromEntity(Transaction entity) {
    return TransactionModel(
      id: entity.id,
      invoiceNo: entity.invoiceNo,
      cashierId: entity.cashierId,
      cashierName: entity.cashierName,
      storeName: entity.storeName,
      storeAddress: entity.storeAddress,
      storePhone: entity.storePhone,
      subtotal: entity.subtotal,
      discountType: entity.discountType,
      discountValue: entity.discountValue,
      discountAmount: entity.discountAmount,
      total: entity.total,
      cashReceived: entity.cashReceived,
      changeAmount: entity.changeAmount,
      createdAt: entity.createdAt,
      items: entity.items,
    );
  }

  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = <String, dynamic>{
      'invoice_no': invoiceNo,
      'cashier_id': cashierId,
      'cashier_name': cashierName,
      'store_name': storeName,
      'store_address': storeAddress,
      'store_phone': storePhone,
      'subtotal': subtotal,
      'discount_type': discountType,
      'discount_value': discountValue,
      'discount_amount': discountAmount,
      'total': total,
      'cash_received': cashReceived,
      'change_amount': changeAmount,
      'created_at': createdAt,
    };
    if (includeId && id != null) {
      map['id'] = id;
    }
    return map;
  }

  Transaction toEntity() {
    return Transaction(
      id: id,
      invoiceNo: invoiceNo,
      cashierId: cashierId,
      cashierName: cashierName,
      storeName: storeName,
      storeAddress: storeAddress,
      storePhone: storePhone,
      subtotal: subtotal,
      discountType: discountType,
      discountValue: discountValue,
      discountAmount: discountAmount,
      total: total,
      cashReceived: cashReceived,
      changeAmount: changeAmount,
      createdAt: createdAt,
      items: items.map((i) {
        if (i is TransactionItemModel) {
          return i.toEntity();
        }
        return i;
      }).toList(),
    );
  }
}

