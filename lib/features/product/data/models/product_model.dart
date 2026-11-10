import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    super.categoryId,
    super.categoryName,
    required super.name,
    required super.price,
    required super.stock,
    super.photoPath,
    super.addonIds = const [],
    super.isDeleted = false,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProductModel.fromMap(
    Map<String, dynamic> map, {
    List<int>? addonIds,
    String? categoryName,
  }) {
    return ProductModel(
      id: map['id'] as int,
      categoryId: map['category_id'] as int?,
      categoryName: categoryName ?? map['category_name'] as String?,
      name: map['name'] as String,
      price: map['price'] as int,
      stock: map['stock'] as int? ?? 0,
      photoPath: map['photo_path'] as String?,
      addonIds: addonIds ?? const [],
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'category_id': categoryId,
      'name': name,
      'price': price,
      'stock': stock,
      'photo_path': photoPath,
      'is_deleted': isDeleted ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      categoryId: product.categoryId,
      categoryName: product.categoryName,
      name: product.name,
      price: product.price,
      stock: product.stock,
      photoPath: product.photoPath,
      addonIds: product.addonIds,
      isDeleted: product.isDeleted,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }
}

