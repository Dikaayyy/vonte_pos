import 'package:equatable/equatable.dart';

enum DiscountType {
  percent,
  fixed,
}

/// Discount specification for cart or transaction.
class Discount extends Equatable {
  final DiscountType type;
  final int value;

  const Discount({
    required this.type,
    required this.value,
  });

  const Discount.none()
      : type = DiscountType.fixed,
        value = 0;

  const Discount.percent(this.value) : type = DiscountType.percent;

  const Discount.fixed(this.value) : type = DiscountType.fixed;

  bool get isNone => value == 0;
  bool get isPercent => type == DiscountType.percent;
  bool get isFixed => type == DiscountType.fixed;

  @override
  List<Object?> get props => [type, value];
}

/// Validation result for discount rules.
class DiscountValidationResult extends Equatable {
  final bool isValid;
  final String? message;

  const DiscountValidationResult.valid()
      : isValid = true,
        message = null;

  const DiscountValidationResult.invalid(this.message) : isValid = false;

  @override
  List<Object?> get props => [isValid, message];
}

