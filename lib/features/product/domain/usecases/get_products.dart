import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProducts {
  final ProductRepository _repository;

  GetProducts(this._repository);

  Future<List<Product>> call({
    int? categoryId,
    String? query,
    bool includeDeleted = false,
  }) {
    return _repository.getProducts(
      categoryId: categoryId,
      query: query,
      includeDeleted: includeDeleted,
    );
  }
}

