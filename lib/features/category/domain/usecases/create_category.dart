import '../../../../core/error/exceptions.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';
import '../validators/category_validator.dart';

class CreateCategory {
  final CategoryRepository _repository;

  const CreateCategory(this._repository);

  Future<Category> call(String name) async {
    final validationError = CategoryValidator.validateName(name);
    if (validationError != null) {
      throw ValidationException(validationError);
    }

    final trimmedName = CategoryValidator.normalizeName(name);
    return _repository.createCategory(trimmedName);
  }
}

