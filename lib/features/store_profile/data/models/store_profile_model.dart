import '../../domain/entities/store_profile.dart';

class StoreProfileModel extends StoreProfile {
  const StoreProfileModel({
    required super.id,
    required super.name,
    required super.address,
    required super.phone,
    required super.receiptFooter,
  });

  factory StoreProfileModel.fromMap(Map<String, dynamic> map) {
    return StoreProfileModel(
      id: map['id'] as int,
      name: map['name'] as String,
      address: map['address'] as String,
      phone: map['phone'] as String,
      receiptFooter: map['receipt_footer'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'receipt_footer': receiptFooter,
    };
  }

  factory StoreProfileModel.fromEntity(StoreProfile entity) {
    return StoreProfileModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      phone: entity.phone,
      receiptFooter: entity.receiptFooter,
    );
  }
}

