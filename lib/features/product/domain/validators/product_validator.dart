import '../../../../core/constants/app_strings.dart';

abstract final class ProductValidator {
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return AppStrings.productNameRequired;
    }
    return null;
  }

  static String? validatePrice(String? priceStr) {
    if (priceStr == null || priceStr.trim().isEmpty) {
      return AppStrings.productPriceNan;
    }
    final parsed = int.tryParse(priceStr.replaceAll('.', '').trim());
    if (parsed == null) {
      return AppStrings.productPriceNan;
    }
    if (parsed <= 0) {
      return AppStrings.productPriceInvalid;
    }
    return null;
  }

  static String? validateStock(String? stockStr) {
    if (stockStr == null || stockStr.trim().isEmpty) {
      return AppStrings.productStockNan;
    }
    final parsed = int.tryParse(stockStr.replaceAll('.', '').trim());
    if (parsed == null) {
      return AppStrings.productStockNan;
    }
    if (parsed < 0) {
      return AppStrings.productStockInvalid;
    }
    return null;
  }

  static String? validateAll({
    required String? name,
    required String? priceStr,
    required String? stockStr,
  }) {
    final nameError = validateName(name);
    if (nameError != null) return nameError;

    final priceError = validatePrice(priceStr);
    if (priceError != null) return priceError;

    final stockError = validateStock(stockStr);
    if (stockError != null) return stockError;

    return null;
  }
}

