import '../../../../core/constants/app_strings.dart';
import '../entities/discount.dart';

/// Calculates and validates discounts according to Rule 4 (Discount Protection).
///
/// Rules:
/// - Percent discount: integer from 0 to 100 inclusive.
/// - Fixed discount: integer from 0 up to subtotal inclusive.
/// - Round half-up with integer arithmetic: `((subtotal * percent + 50) ~/ 100)`.
/// - Total is never negative: `total = subtotal - discount_amount >= 0`.
class DiscountCalculator {
  const DiscountCalculator();

  /// Validates [discount] against [subtotal].
  DiscountValidationResult validate(Discount discount, int subtotal) {
    if (subtotal < 0) {
      return const DiscountValidationResult.invalid('Subtotal tidak valid.');
    }

    switch (discount.type) {
      case DiscountType.percent:
        if (discount.value < 0 || discount.value > 100) {
          return const DiscountValidationResult.invalid(
            AppStrings.discountPercentOutOfRange,
          );
        }
        return const DiscountValidationResult.valid();

      case DiscountType.fixed:
        if (discount.value < 0) {
          return const DiscountValidationResult.invalid(
            AppStrings.discountFixedNegative,
          );
        }
        if (discount.value > subtotal) {
          return const DiscountValidationResult.invalid(
            AppStrings.discountFixedExceedsSubtotal,
          );
        }
        return const DiscountValidationResult.valid();
    }
  }

  /// Calculates discount amount in integer rupiah.
  /// Throws [ArgumentError] if [discount] violates validation rules for [subtotal].
  int calculateDiscountAmount(Discount discount, int subtotal) {
    final validation = validate(discount, subtotal);
    if (!validation.isValid) {
      throw ArgumentError(validation.message);
    }

    if (subtotal <= 0) return 0;

    switch (discount.type) {
      case DiscountType.percent:
        final amount = ((subtotal * discount.value + 50) ~/ 100);
        return amount > subtotal ? subtotal : amount;

      case DiscountType.fixed:
        return discount.value;
    }
  }

  /// Calculates final payable total: `max(0, subtotal - discountAmount)`.
  int calculateTotal(Discount discount, int subtotal) {
    final discountAmount = calculateDiscountAmount(discount, subtotal);
    final total = subtotal - discountAmount;
    return total < 0 ? 0 : total;
  }
}

