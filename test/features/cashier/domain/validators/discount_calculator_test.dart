import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/features/cashier/domain/entities/discount.dart';
import 'package:vonte_pos/features/cashier/domain/validators/discount_calculator.dart';

void main() {
  const calculator = DiscountCalculator();

  group('DiscountCalculator - Rule 4 (Discount Protection)', () {
    const subtotal = 50000;

    group('Percent Discount Validation & Calculation', () {
      test('persen 0 is valid and yields 0 discount', () {
        const discount = Discount.percent(0);
        final validation = calculator.validate(discount, subtotal);
        expect(validation.isValid, isTrue);

        final amount = calculator.calculateDiscountAmount(discount, subtotal);
        expect(amount, 0);

        final total = calculator.calculateTotal(discount, subtotal);
        expect(total, subtotal);
      });

      test('persen 100 is valid and yields full subtotal discount', () {
        const discount = Discount.percent(100);
        final validation = calculator.validate(discount, subtotal);
        expect(validation.isValid, isTrue);

        final amount = calculator.calculateDiscountAmount(discount, subtotal);
        expect(amount, subtotal);

        final total = calculator.calculateTotal(discount, subtotal);
        expect(total, 0);
      });

      test('persen 101 is invalid and throws ArgumentError on calculate', () {
        const discount = Discount.percent(101);
        final validation = calculator.validate(discount, subtotal);
        expect(validation.isValid, isFalse);
        expect(validation.message, isNotNull);

        expect(
          () => calculator.calculateDiscountAmount(discount, subtotal),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('persen -1 is invalid and throws ArgumentError on calculate', () {
        const discount = Discount.percent(-1);
        final validation = calculator.validate(discount, subtotal);
        expect(validation.isValid, isFalse);
        expect(validation.message, isNotNull);

        expect(
          () => calculator.calculateDiscountAmount(discount, subtotal),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Fixed Discount Validation & Calculation', () {
      test('fixed sama dengan subtotal is valid and yields full subtotal discount', () {
        final discount = Discount.fixed(subtotal);
        final validation = calculator.validate(discount, subtotal);
        expect(validation.isValid, isTrue);

        final amount = calculator.calculateDiscountAmount(discount, subtotal);
        expect(amount, subtotal);

        final total = calculator.calculateTotal(discount, subtotal);
        expect(total, 0);
      });

      test('fixed lebih dari subtotal is invalid and throws ArgumentError on calculate', () {
        final discount = Discount.fixed(subtotal + 1);
        final validation = calculator.validate(discount, subtotal);
        expect(validation.isValid, isFalse);
        expect(validation.message, isNotNull);

        expect(
          () => calculator.calculateDiscountAmount(discount, subtotal),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('fixed negatif is invalid and throws ArgumentError on calculate', () {
        const discount = Discount.fixed(-1);
        final validation = calculator.validate(discount, subtotal);
        expect(validation.isValid, isFalse);
        expect(validation.message, isNotNull);

        expect(
          () => calculator.calculateDiscountAmount(discount, subtotal),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Subtotal 0 scenarios', () {
      test('subtotal 0 with percent 0 is valid and yields 0', () {
        const discount = Discount.percent(0);
        final validation = calculator.validate(discount, 0);
        expect(validation.isValid, isTrue);
        expect(calculator.calculateDiscountAmount(discount, 0), 0);
        expect(calculator.calculateTotal(discount, 0), 0);
      });

      test('subtotal 0 with percent 100 is valid and yields 0', () {
        const discount = Discount.percent(100);
        final validation = calculator.validate(discount, 0);
        expect(validation.isValid, isTrue);
        expect(calculator.calculateDiscountAmount(discount, 0), 0);
        expect(calculator.calculateTotal(discount, 0), 0);
      });

      test('subtotal 0 with fixed 0 is valid and yields 0', () {
        const discount = Discount.fixed(0);
        final validation = calculator.validate(discount, 0);
        expect(validation.isValid, isTrue);
        expect(calculator.calculateDiscountAmount(discount, 0), 0);
        expect(calculator.calculateTotal(discount, 0), 0);
      });

      test('subtotal 0 with fixed > 0 is invalid', () {
        const discount = Discount.fixed(5000);
        final validation = calculator.validate(discount, 0);
        expect(validation.isValid, isFalse);
        expect(
          () => calculator.calculateDiscountAmount(discount, 0),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Half-up Rounding with Integer Arithmetic', () {
      test('subtotal 10005 dengan 15% menghasilkan 1501', () {
        const discount = Discount.percent(15);
        final amount = calculator.calculateDiscountAmount(discount, 10005);
        expect(amount, 1501);

        final total = calculator.calculateTotal(discount, 10005);
        expect(total, 8504);
      });

      test('subtotal 10000 dengan 15% menghasilkan 1500', () {
        const discount = Discount.percent(15);
        final amount = calculator.calculateDiscountAmount(discount, 10000);
        expect(amount, 1500);

        final total = calculator.calculateTotal(discount, 10000);
        expect(total, 8500);
      });

      test('subtotal 3 dengan 50% menghasilkan 2 (1.5 rounds up to 2)', () {
        const discount = Discount.percent(50);
        final amount = calculator.calculateDiscountAmount(discount, 3);
        expect(amount, 2);
      });

      test('subtotal 1 dengan 49% menghasilkan 0 (0.49 rounds down to 0)', () {
        const discount = Discount.percent(49);
        final amount = calculator.calculateDiscountAmount(discount, 1);
        expect(amount, 0);
      });

      test('subtotal 1 dengan 50% menghasilkan 1 (0.50 rounds up to 1)', () {
        const discount = Discount.percent(50);
        final amount = calculator.calculateDiscountAmount(discount, 1);
        expect(amount, 1);
      });
    });

    test('Total tidak pernah negatif', () {
      const discount = Discount.percent(100);
      final total = calculator.calculateTotal(discount, 12500);
      expect(total, 0);
      expect(total >= 0, isTrue);
    });
  });
}

