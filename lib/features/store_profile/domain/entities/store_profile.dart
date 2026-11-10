import 'package:equatable/equatable.dart';

class StoreProfile extends Equatable {
  final int id;
  final String name;
  final String address;
  final String phone;
  final String receiptFooter;

  const StoreProfile({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.receiptFooter,
  });

  StoreProfile copyWith({
    int? id,
    String? name,
    String? address,
    String? phone,
    String? receiptFooter,
  }) {
    return StoreProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      receiptFooter: receiptFooter ?? this.receiptFooter,
    );
  }

  @override
  List<Object?> get props => [id, name, address, phone, receiptFooter];
}

