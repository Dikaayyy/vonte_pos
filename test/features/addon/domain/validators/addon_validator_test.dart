import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/core/constants/app_constants.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/features/addon/domain/entities/addon.dart';
import 'package:vonte_pos/features/addon/domain/validators/addon_validator.dart';

void main() {
  group('AddonValidator', () {
    group('validateName', () {
      test('returns error when name is null', () {
        expect(
          AddonValidator.validateName(null),
          AppStrings.addonNameRequired,
        );
      });

      test('returns error when name is empty', () {
        expect(
          AddonValidator.validateName(''),
          AppStrings.addonNameRequired,
        );
      });

      test('returns error when name is whitespace only', () {
        expect(
          AddonValidator.validateName('   \t\n  '),
          AppStrings.addonNameRequired,
        );
      });

      test('returns null when name is valid', () {
        expect(AddonValidator.validateName('Extra Shot'), isNull);
      });
    });

    group('validatePrice', () {
      test('returns error when price is null', () {
        expect(
          AddonValidator.validatePrice(null),
          AppStrings.addonPriceInvalid,
        );
      });

      test('returns error when integer price is negative', () {
        expect(
          AddonValidator.validatePrice(-1),
          AppStrings.addonPriceInvalid,
        );
      });

      test('returns error when string price is negative', () {
        expect(
          AddonValidator.validatePrice('-5000'),
          AppStrings.addonPriceInvalid,
        );
      });

      test('returns error when string price is not a number', () {
        expect(
          AddonValidator.validatePrice('gratis'),
          AppStrings.addonPriceNan,
        );
      });

      test('returns error when string price is empty', () {
        expect(
          AddonValidator.validatePrice('   '),
          AppStrings.addonPriceInvalid,
        );
      });

      test('returns null when price is 0 (free add-on is allowed)', () {
        expect(AddonValidator.validatePrice(0), isNull);
        expect(AddonValidator.validatePrice('0'), isNull);
      });

      test('returns null when price is positive', () {
        expect(AddonValidator.validatePrice(5000), isNull);
        expect(AddonValidator.validatePrice('5000'), isNull);
      });
    });

    group('validateStock', () {
      test('returns error when stock is null', () {
        expect(
          AddonValidator.validateStock(null),
          AppStrings.addonStockInvalid,
        );
      });

      test('returns error when integer stock is negative', () {
        expect(
          AddonValidator.validateStock(-1),
          AppStrings.addonStockInvalid,
        );
      });

      test('returns error when string stock is negative', () {
        expect(
          AddonValidator.validateStock('-10'),
          AppStrings.addonStockInvalid,
        );
      });

      test('returns error when string stock is not a number', () {
        expect(
          AddonValidator.validateStock('sepuluh'),
          AppStrings.addonStockNan,
        );
      });

      test('returns error when string stock is empty', () {
        expect(
          AddonValidator.validateStock(''),
          AppStrings.addonStockInvalid,
        );
      });

      test('returns null when stock is 0 (out of stock allowed to record)', () {
        expect(AddonValidator.validateStock(0), isNull);
        expect(AddonValidator.validateStock('0'), isNull);
      });

      test('returns null when stock is positive', () {
        expect(AddonValidator.validateStock(10), isNull);
        expect(AddonValidator.validateStock('10'), isNull);
      });
    });

    group('normalizeName', () {
      test('trims leading and trailing whitespace', () {
        expect(AddonValidator.normalizeName('  Oat Milk  '), 'Oat Milk');
      });
    });
  });

  group('Addon Entity stock thresholds', () {
    test('isOutOfStock is true when stock <= 0 and not deleted', () {
      const addonZero = Addon(id: 1, name: 'Topping', price: 2000, stock: 0);
      const addonNegative = Addon(id: 1, name: 'Topping', price: 2000, stock: -1);
      const addonPositive = Addon(id: 1, name: 'Topping', price: 2000, stock: 1);

      expect(addonZero.isOutOfStock, isTrue);
      expect(addonNegative.isOutOfStock, isTrue);
      expect(addonPositive.isOutOfStock, isFalse);
    });

    test('isLowStock uses AppConstants.lowStockThreshold', () {
      const threshold = AppConstants.lowStockThreshold;

      const addonAtThreshold = Addon(
        id: 1,
        name: 'Extra Shot',
        price: 3000,
        stock: threshold,
      );
      const addonBelowThreshold = Addon(
        id: 1,
        name: 'Extra Shot',
        price: 3000,
        stock: threshold - 1,
      );
      const addonAboveThreshold = Addon(
        id: 1,
        name: 'Extra Shot',
        price: 3000,
        stock: threshold + 1,
      );
      const addonZero = Addon(
        id: 1,
        name: 'Extra Shot',
        price: 3000,
        stock: 0,
      );

      expect(addonAtThreshold.isLowStock, isTrue);
      expect(addonBelowThreshold.isLowStock, isTrue);
      expect(addonAboveThreshold.isLowStock, isFalse);
      // Stock 0 is out of stock, not low stock
      expect(addonZero.isLowStock, isFalse);
    });

    test('isLowStock and isOutOfStock are false when soft-deleted', () {
      const deletedZero = Addon(
        id: 1,
        name: 'Deleted',
        price: 2000,
        stock: 0,
        isDeleted: true,
      );
      const deletedLow = Addon(
        id: 2,
        name: 'Deleted Low',
        price: 2000,
        stock: 2,
        isDeleted: true,
      );

      expect(deletedZero.isOutOfStock, isFalse);
      expect(deletedLow.isLowStock, isFalse);
    });
  });
}

