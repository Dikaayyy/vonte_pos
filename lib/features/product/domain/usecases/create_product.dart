import '../entities/product.dart';
import '../repositories/product_repository.dart';

class CreateProduct {
  final ProductRepository _repository;

  CreateProduct(this._repository);

  Future<Product> call({
    required String name,
    int? categoryId,
    required int price,
    required int stock,
    String? photoPath,
    List<int> addonIds = const [],
  }) {
    return _repository.createProduct(
      name: name,
      categoryId: categoryId,
      price: price,
      stock: stock,
      photoPath: photoPath,
      addonIds: addonIds,
    );
  }
}

