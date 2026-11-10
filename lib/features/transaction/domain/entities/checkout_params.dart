import 'package:equatable/equatable.dart';

import '../../../cashier/domain/entities/cart_line.dart';
import '../../../cashier/domain/entities/discount.dart';

/// Parameters for initiating a checkout transaction.
class CheckoutParams extends Equatable {
  final List<CartLine> lines;
  final Discount discount;
  final int cashReceived;
  final int cashierId;
  final String cashierName;
  final String? storeName;
  final String? storeAddress;
  final String? storePhone;
  final int? createdAt;

  const CheckoutParams({
    required this.lines,
    this.discount = const Discount.none(),
    required this.cashReceived,
    required this.cashierId,
    required this.cashierName,
    this.storeName,
    this.storeAddress,
    this.storePhone,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        lines,
        discount,
        cashReceived,
        cashierId,
        cashierName,
        storeName,
        storeAddress,
        storePhone,
        createdAt,
      ];
}

