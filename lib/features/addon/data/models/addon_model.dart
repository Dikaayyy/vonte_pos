import '../../domain/entities/addon.dart';

class AddonModel extends Addon {
  const AddonModel({
    required super.id,
    required super.name,
    required super.price,
    required super.stock,
    super.isDeleted = false,
  });

  factory AddonModel.fromMap(Map<String, dynamic> map) {
    return AddonModel(
      id: map['id'] as int,
      name: map['name'] as String,
      price: (map['price'] as num).toInt(),
      stock: (map['stock'] as num).toInt(),
      isDeleted: (map['is_deleted'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }
}

