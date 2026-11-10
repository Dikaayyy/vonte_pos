import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/features/product/domain/validators/product_validator.dart';

void main() {
  group('ProductValidator', () {
    group('validateName', () {
      test('returns error when name is null or whitespace', () {
        expect(ProductValidator.validateName(null), AppStrings.productNameRequired);
        expect(ProductValidator.validateName(''), AppStrings.productNameRequired);
        expect(ProductValidator.validateName('   '), AppStrings.productNameRequired);
      });

      test('returns null when name is valid', () {
        expect(ProductValidator.validateName('Kopi Susu Aren'), isNull);
      });
    });

    group('validatePrice', () {
      test('returns error when price is null, empty, or not a number', () {
        expect(ProductValidator.validatePrice(null), AppStrings.productPriceNan);
        expect(ProductValidator.validatePrice(''), AppStrings.productPriceNan);
        expect(ProductValidator.validatePrice('abc'), AppStrings.productPriceNan);
      });

      test('returns error when price is 0 or negative', () {
        expect(ProductValidator.validatePrice('0'), AppStrings.productPriceInvalid);
        expect(ProductValidator.validatePrice('-1000'), AppStrings.productPriceInvalid);
      });

      test('returns null when price is greater than 0', () {
        expect(ProductValidator.validatePrice('15000'), isNull);
        expect(ProductValidator.validatePrice('15.000'), isNull);
      });
    });

    group('validateStock', () {
      test('returns error when stock is null, empty, or not a number', () {
        expect(ProductValidator.validateStock(null), AppStrings.productStockNan);
        expect(ProductValidator.validateStock(''), AppStrings.productStockNan);
        expect(ProductValidator.validateStock('xyz'), AppStrings.productStockNan);
      });

      test('returns error when stock is negative', () {
        expect(ProductValidator.validateStock('-1'), AppStrings.productStockInvalid);
      });

      test('returns null when stock is 0 or positive', () {
        expect(ProductValidator.validateStock('0'), isNull);
        expect(ProductValidator.validateStock('25'), isNull);
        expect(ProductValidator.validateStock('1.000'), isNull);
      });
    });

    group('validateAll', () {
      test('returns first encountered error', () {
        expect(
          ProductValidator.validateAll(name: '', priceStr: '1000', stockStr: '5'),
          AppStrings.productNameRequired,
        );
        expect(
          ProductValidator.validateAll(name: 'Kopi', priceStr: '0', stockStr: '5'),
          AppStrings.productPriceInvalid,
        );
        expect(
          ProductValidator.validateAll(name: 'Kopi', priceStr: '1000', stockStr: '-2'),
          AppStrings.productStockInvalid,
        );
      });

      test('returns null when all fields are valid', () {
        expect(
          ProductValidator.validateAll(name: 'Kopi Susu', priceStr: '15000', stockStr: '10'),
          isNull,
        );
      });
    });
  });
}

