import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/features/category/domain/validators/category_validator.dart';

void main() {
  group('CategoryValidator', () {
    test('returns error when category name is null', () {
      final result = CategoryValidator.validateName(null);
      expect(result, AppStrings.categoryNameRequired);
    });

    test('returns error when category name is empty', () {
      final result = CategoryValidator.validateName('');
      expect(result, AppStrings.categoryNameRequired);
    });

    test('returns error when category name is only whitespace', () {
      final result = CategoryValidator.validateName('   \t\n  ');
      expect(result, AppStrings.categoryNameRequired);
    });

    test('returns null when category name is valid', () {
      final result = CategoryValidator.validateName('Minuman Dingin');
      expect(result, isNull);
    });

    test('normalizeName trims leading and trailing whitespaces', () {
      expect(CategoryValidator.normalizeName('  Kopi Susu  '), 'Kopi Susu');
      expect(CategoryValidator.normalizeName('\tMakanan Ringan\n'), 'Makanan Ringan');
    });
  });
}

