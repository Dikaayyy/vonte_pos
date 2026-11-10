import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';

class Addon extends Equatable {
  final int id;
  final String name;
  final int price;
  final int stock;
  final bool isDeleted;

  const Addon({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.isDeleted = false,
  });

  /// True when addon is active and stock is at or below [AppConstants.lowStockThreshold], but not 0.
  bool get isLowStock =>
      !isDeleted && stock > 0 && stock <= AppConstants.lowStockThreshold;

  /// True when addon has run out of stock.
  bool get isOutOfStock => !isDeleted && stock <= 0;

  Addon copyWith({
    int? id,
    String? name,
    int? price,
    int? stock,
    bool? isDeleted,
  }) {
    return Addon(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [id, name, price, stock, isDeleted];
}

