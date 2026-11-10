import 'package:equatable/equatable.dart';

import '../validators/discount_calculator.dart';
import 'cart_line.dart';
import 'discount.dart';

/// Financial totals for a cart or checkout order.
class CartTotals extends Equatable {
  final int subtotal;
  final int discountAmount;
  final int total;

  const CartTotals({
    required this.subtotal,
    required this.discountAmount,
    required this.total,
  });

  const CartTotals.zero()
      : subtotal = 0,
        discountAmount = 0,
        total = 0;

  /// Alias for discount amount in rupiah.
  int get discount => discountAmount;

  /// Computes cart totals from lines and an optional [Discount].
  factory CartTotals.compute({
    required Iterable<CartLine> lines,
    Discount discount = const Discount.none(),
    DiscountCalculator calculator = const DiscountCalculator(),
  }) {
    final subtotal = lines.fold<int>(0, (sum, line) => sum + line.lineTotal);
    final discountAmount = calculator.calculateDiscountAmount(discount, subtotal);
    final total = subtotal - discountAmount;
    return CartTotals(
      subtotal: subtotal,
      discountAmount: discountAmount,
      total: total < 0 ? 0 : total,
    );
  }

  /// Computes cart totals from a pre-calculated [subtotal] and [Discount].
  factory CartTotals.fromSubtotal({
    required int subtotal,
    Discount discount = const Discount.none(),
    DiscountCalculator calculator = const DiscountCalculator(),
  }) {
    final discountAmount = calculator.calculateDiscountAmount(discount, subtotal);
    final total = subtotal - discountAmount;
    return CartTotals(
      subtotal: subtotal,
      discountAmount: discountAmount,
      total: total < 0 ? 0 : total,
    );
  }

  @override
  List<Object?> get props => [subtotal, discountAmount, total];
}

