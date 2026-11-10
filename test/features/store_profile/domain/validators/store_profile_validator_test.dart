import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/features/store_profile/domain/validators/store_profile_validator.dart';

void main() {
  group('StoreProfileValidator', () {
    test('validateName returns error when empty or null, null when valid', () {
      expect(StoreProfileValidator.validateName(null), AppStrings.storeNameRequired);
      expect(StoreProfileValidator.validateName(''), AppStrings.storeNameRequired);
      expect(StoreProfileValidator.validateName('   '), AppStrings.storeNameRequired);
      expect(StoreProfileValidator.validateName('Kedai Kopi Vonte'), isNull);
    });

    test('validateAddress returns error when empty or null, null when valid', () {
      expect(StoreProfileValidator.validateAddress(null), AppStrings.storeAddressRequired);
      expect(StoreProfileValidator.validateAddress(''), AppStrings.storeAddressRequired);
      expect(StoreProfileValidator.validateAddress('   '), AppStrings.storeAddressRequired);
      expect(StoreProfileValidator.validateAddress('Jl. Mawar No. 12'), isNull);
    });

    test('validatePhone returns error when empty or null, null when valid', () {
      expect(StoreProfileValidator.validatePhone(null), AppStrings.storePhoneRequired);
      expect(StoreProfileValidator.validatePhone(''), AppStrings.storePhoneRequired);
      expect(StoreProfileValidator.validatePhone('   '), AppStrings.storePhoneRequired);
      expect(StoreProfileValidator.validatePhone('08123456789'), isNull);
    });

    test('validateReceiptFooter returns error when empty or null, null when valid', () {
      expect(StoreProfileValidator.validateReceiptFooter(null),
          AppStrings.storeReceiptFooterRequired);
      expect(StoreProfileValidator.validateReceiptFooter(''),
          AppStrings.storeReceiptFooterRequired);
      expect(StoreProfileValidator.validateReceiptFooter('   '),
          AppStrings.storeReceiptFooterRequired);
      expect(StoreProfileValidator.validateReceiptFooter('Terima kasih!'), isNull);
    });
  });
}

