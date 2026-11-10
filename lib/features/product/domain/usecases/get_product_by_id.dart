import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductById {
  final ProductRepository _repository;

  GetProductById(this._repository);

  Future<Product?> call(int id) {
    return _repository.getProductById(id);
  }
}

