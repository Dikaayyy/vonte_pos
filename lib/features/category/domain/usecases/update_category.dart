import '../../../../core/error/exceptions.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';
import '../validators/category_validator.dart';

class UpdateCategory {
  final CategoryRepository _repository;

  const UpdateCategory(this._repository);

  Future<Category> call({
    required int id,
    required String name,
  }) async {
    final validationError = CategoryValidator.validateName(name);
    if (validationError != null) {
      throw ValidationException(validationError);
    }

    final trimmedName = CategoryValidator.normalizeName(name);
    return _repository.updateCategory(id: id, name: trimmedName);
  }
}

