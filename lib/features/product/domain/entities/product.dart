import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';

class Product extends Equatable {
  final int id;
  final int? categoryId;
  final String? categoryName;
  final String name;
  final int price;
  final int stock;
  final String? photoPath;
  final List<int> addonIds;
  final bool isDeleted;
  final int createdAt;
  final int updatedAt;

  const Product({
    required this.id,
    this.categoryId,
    this.categoryName,
    required this.name,
    required this.price,
    required this.stock,
    this.photoPath,
    this.addonIds = const [],
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOutOfStock => stock <= 0;

  bool get hasLowStock => stock > 0 && stock <= AppConstants.lowStockThreshold;

  bool get hasAddons => addonIds.isNotEmpty;

  Product copyWith({
    int? id,
    int? categoryId,
    String? categoryName,
    String? name,
    int? price,
    int? stock,
    String? photoPath,
    List<int>? addonIds,
    bool? isDeleted,
    int? createdAt,
    int? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      photoPath: photoPath ?? this.photoPath,
      addonIds: addonIds ?? this.addonIds,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        categoryId,
        categoryName,
        name,
        price,
        stock,
        photoPath,
        addonIds,
        isDeleted,
        createdAt,
        updatedAt,
      ];
}

