import 'package:equatable/equatable.dart';

import 'transaction_item.dart';

/// Entity representing a completed point-of-sale transaction snapshot.
class Transaction extends Equatable {
  final int? id;
  final String invoiceNo;
  final int cashierId;
  final String cashierName;
  final String storeName;
  final String storeAddress;
  final String storePhone;
  final int subtotal;
  final String discountType;
  final int discountValue;
  final int discountAmount;
  final int total;
  final int cashReceived;
  final int changeAmount;
  final int createdAt;
  final List<TransactionItem> items;

  const Transaction({
    this.id,
    required this.invoiceNo,
    required this.cashierId,
    required this.cashierName,
    required this.storeName,
    required this.storeAddress,
    required this.storePhone,
    required this.subtotal,
    required this.discountType,
    required this.discountValue,
    required this.discountAmount,
    required this.total,
    required this.cashReceived,
    required this.changeAmount,
    required this.createdAt,
    this.items = const [],
  });

  Transaction copyWith({
    int? id,
    String? invoiceNo,
    int? cashierId,
    String? cashierName,
    String? storeName,
    String? storeAddress,
    String? storePhone,
    int? subtotal,
    String? discountType,
    int? discountValue,
    int? discountAmount,
    int? total,
    int? cashReceived,
    int? changeAmount,
    int? createdAt,
    List<TransactionItem>? items,
  }) {
    return Transaction(
      id: id ?? this.id,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      cashierId: cashierId ?? this.cashierId,
      cashierName: cashierName ?? this.cashierName,
      storeName: storeName ?? this.storeName,
      storeAddress: storeAddress ?? this.storeAddress,
      storePhone: storePhone ?? this.storePhone,
      subtotal: subtotal ?? this.subtotal,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      discountAmount: discountAmount ?? this.discountAmount,
      total: total ?? this.total,
      cashReceived: cashReceived ?? this.cashReceived,
      changeAmount: changeAmount ?? this.changeAmount,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [
        id,
        invoiceNo,
        cashierId,
        cashierName,
        storeName,
        storeAddress,
        storePhone,
        subtotal,
        discountType,
        discountValue,
        discountAmount,
        total,
        cashReceived,
        changeAmount,
        createdAt,
        items,
      ];
}

