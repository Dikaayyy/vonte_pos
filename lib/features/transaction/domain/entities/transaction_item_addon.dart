import 'package:equatable/equatable.dart';

/// Snapshot entity for an add-on attached to a transaction item line.
class TransactionItemAddon extends Equatable {
  final int? id;
  final int? transactionItemId;
  final int addonId;
  final String addonName;
  final int addonPrice;
  final int qty;
  final int lineTotal;

  const TransactionItemAddon({
    this.id,
    this.transactionItemId,
    required this.addonId,
    required this.addonName,
    required this.addonPrice,
    required this.qty,
    required this.lineTotal,
  });

  TransactionItemAddon copyWith({
    int? id,
    int? transactionItemId,
    int? addonId,
    String? addonName,
    int? addonPrice,
    int? qty,
    int? lineTotal,
  }) {
    return TransactionItemAddon(
      id: id ?? this.id,
      transactionItemId: transactionItemId ?? this.transactionItemId,
      addonId: addonId ?? this.addonId,
      addonName: addonName ?? this.addonName,
      addonPrice: addonPrice ?? this.addonPrice,
      qty: qty ?? this.qty,
      lineTotal: lineTotal ?? this.lineTotal,
    );
  }

  @override
  List<Object?> get props => [
        id,
        transactionItemId,
        addonId,
        addonName,
        addonPrice,
        qty,
        lineTotal,
      ];
}

