import '../repositories/category_repository.dart';

class DeleteCategory {
  final CategoryRepository _repository;

  const DeleteCategory(this._repository);

  Future<void> call(int id) {
    return _repository.deleteCategory(id);
  }
}

