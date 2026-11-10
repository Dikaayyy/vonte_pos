import 'package:equatable/equatable.dart';

import '../../domain/entities/cart_line.dart';
import '../../domain/entities/cart_totals.dart';
import '../../domain/entities/discount.dart';

/// State of the cashier shopping cart.
class CartState extends Equatable {
  final List<CartLine> items;
  final Discount discount;
  final CartTotals totals;
  final String? errorMessage;

  const CartState({
    this.items = const [],
    this.discount = const Discount.none(),
    this.totals = const CartTotals.zero(),
    this.errorMessage,
  });

  const CartState.initial() : this();

  List<CartLine> get lines => items;

  int get itemCount => items.fold<int>(0, (sum, item) => sum + item.qty);

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  int get subtotal => totals.subtotal;

  int get discountAmount => totals.discountAmount;

  int get total => totals.total;

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  CartState copyWith({
    List<CartLine>? items,
    Discount? discount,
    CartTotals? totals,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CartState(
      items: items ?? this.items,
      discount: discount ?? this.discount,
      totals: totals ?? this.totals,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [items, discount, totals, errorMessage];
}

