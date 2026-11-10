import 'package:equatable/equatable.dart';

import '../../../addon/domain/entities/addon.dart';

/// Attached add-on snapshot for a cart item line.
class CartAddon extends Equatable {
  final int id;
  final String name;
  final int price;

  const CartAddon({
    required this.id,
    required this.name,
    required this.price,
  });

  /// Creates a [CartAddon] snapshot from an [Addon] entity.
  factory CartAddon.fromAddon(Addon addon) {
    return CartAddon(
      id: addon.id,
      name: addon.name,
      price: addon.price,
    );
  }

  @override
  List<Object?> get props => [id, name, price];
}

/// Represents an item line in the cart.
///
/// Rule 1: Cart line identity = product + set of attached add-ons (order-independent).
/// Adding the same combination increments quantity rather than creating a separate line.
class CartLine extends Equatable {
  final int productId;
  final String productName;
  final int unitPrice;
  final int qty;
  final List<CartAddon> addons;

  CartLine({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.qty,
    List<CartAddon> addons = const [],
  }) : addons = List.unmodifiable(
          List<CartAddon>.from(addons)..sort((a, b) => a.id.compareTo(b.id)),
        );

  String get name => productName;
  int get price => unitPrice;

  /// Unique key representing the line identity (productId + sorted addon IDs).
  String get identityKey =>
      '$productId:[${addons.map((addon) => addon.id).join(',')}]';

  /// Returns true if this line has the same combination of product and addons as [other].
  bool hasSameIdentity(CartLine other) => identityKey == other.identityKey;

  /// Total price of all attached addons for a single unit.
  int get addonsUnitPrice => addons.fold<int>(0, (sum, a) => sum + a.price);

  /// Total unit price including product base price and all attached addons.
  int get totalUnitPrice => unitPrice + addonsUnitPrice;

  /// Total line price = `totalUnitPrice * qty`.
  int get lineTotal => totalUnitPrice * qty;

  CartLine copyWith({
    int? productId,
    String? productName,
    int? unitPrice,
    int? qty,
    List<CartAddon>? addons,
  }) {
    return CartLine(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      qty: qty ?? this.qty,
      addons: addons ?? this.addons,
    );
  }

  @override
  List<Object?> get props => [productId, productName, unitPrice, qty, addons];
}

