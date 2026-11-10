import '../entities/product.dart';
import '../repositories/product_repository.dart';

class UpdateProduct {
  final ProductRepository _repository;

  UpdateProduct(this._repository);

  Future<Product> call({
    required int id,
    required String name,
    int? categoryId,
    required int price,
    required int stock,
    String? photoPath,
    List<int> addonIds = const [],
  }) {
    return _repository.updateProduct(
      id: id,
      name: name,
      categoryId: categoryId,
      price: price,
      stock: stock,
      photoPath: photoPath,
      addonIds: addonIds,
    );
  }
}

