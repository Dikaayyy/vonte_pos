import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int id;
  final String name;
  final int productCount;

  const Category({
    required this.id,
    required this.name,
    this.productCount = 0,
  });

  Category copyWith({
    int? id,
    String? name,
    int? productCount,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      productCount: productCount ?? this.productCount,
    );
  }

  @override
  List<Object?> get props => [id, name, productCount];
}

