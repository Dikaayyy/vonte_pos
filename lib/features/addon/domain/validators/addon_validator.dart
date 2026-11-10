import '../../../../core/constants/app_strings.dart';

abstract final class AddonValidator {
  /// Validates addon name. Name must not be empty or whitespace only.
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return AppStrings.addonNameRequired;
    }
    return null;
  }

  /// Validates price. Price must be a non-negative integer (>= 0).
  static String? validatePrice(dynamic value) {
    if (value == null) {
      return AppStrings.addonPriceInvalid;
    }

    final int? price;
    if (value is int) {
      price = value;
    } else if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return AppStrings.addonPriceInvalid;
      }
      price = int.tryParse(trimmed);
      if (price == null) {
        return AppStrings.addonPriceNan;
      }
    } else {
      return AppStrings.addonPriceNan;
    }

    if (price < 0) {
      return AppStrings.addonPriceInvalid;
    }
    return null;
  }

  /// Validates addon individual stock. Stock must be a non-negative integer (>= 0).
  static String? validateStock(dynamic value) {
    if (value == null) {
      return AppStrings.addonStockInvalid;
    }

    final int? stock;
    if (value is int) {
      stock = value;
    } else if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return AppStrings.addonStockInvalid;
      }
      stock = int.tryParse(trimmed);
      if (stock == null) {
        return AppStrings.addonStockNan;
      }
    } else {
      return AppStrings.addonStockNan;
    }

    if (stock < 0) {
      return AppStrings.addonStockInvalid;
    }
    return null;
  }

  /// Returns trimmed name.
  static String normalizeName(String name) => name.trim();
}

