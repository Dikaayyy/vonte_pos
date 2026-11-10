import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategories {
  final CategoryRepository _repository;

  const GetCategories(this._repository);

  Future<List<Category>> call() {
    return _repository.getCategories();
  }
}

