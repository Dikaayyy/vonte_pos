import '../../../../core/constants/app_strings.dart';

abstract final class CategoryValidator {
  /// Validates that category name is present and non-empty after trimming.
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return AppStrings.categoryNameRequired;
    }
    return null;
  }

  /// Trims whitespace from category name.
  static String normalizeName(String name) {
    return name.trim();
  }
}

