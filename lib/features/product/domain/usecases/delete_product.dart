import '../repositories/product_repository.dart';

class DeleteProduct {
  final ProductRepository _repository;

  DeleteProduct(this._repository);

  Future<void> call(int id) {
    return _repository.deleteProduct(id);
  }
}

