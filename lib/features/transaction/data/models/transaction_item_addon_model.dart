import '../../domain/entities/transaction_item_addon.dart';

class TransactionItemAddonModel extends TransactionItemAddon {
  const TransactionItemAddonModel({
    super.id,
    super.transactionItemId,
    required super.addonId,
    required super.addonName,
    required super.addonPrice,
    required super.qty,
    required super.lineTotal,
  });

  factory TransactionItemAddonModel.fromMap(Map<String, dynamic> map) {
    return TransactionItemAddonModel(
      id: map['id'] as int?,
      transactionItemId: map['transaction_item_id'] as int?,
      addonId: map['addon_id'] as int,
      addonName: map['addon_name'] as String,
      addonPrice: map['addon_price'] as int,
      qty: map['qty'] as int,
      lineTotal: map['line_total'] as int,
    );
  }

  factory TransactionItemAddonModel.fromEntity(TransactionItemAddon entity) {
    return TransactionItemAddonModel(
      id: entity.id,
      transactionItemId: entity.transactionItemId,
      addonId: entity.addonId,
      addonName: entity.addonName,
      addonPrice: entity.addonPrice,
      qty: entity.qty,
      lineTotal: entity.lineTotal,
    );
  }

  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = <String, dynamic>{
      'transaction_item_id': transactionItemId,
      'addon_id': addonId,
      'addon_name': addonName,
      'addon_price': addonPrice,
      'qty': qty,
      'line_total': lineTotal,
    };
    if (includeId && id != null) {
      map['id'] = id;
    }
    return map;
  }

  TransactionItemAddon toEntity() {
    return TransactionItemAddon(
      id: id,
      transactionItemId: transactionItemId,
      addonId: addonId,
      addonName: addonName,
      addonPrice: addonPrice,
      qty: qty,
      lineTotal: lineTotal,
    );
  }
}

