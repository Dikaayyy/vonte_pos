import '../../../../core/constants/app_strings.dart';

abstract final class StoreProfileValidator {
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return AppStrings.storeNameRequired;
    }
    return null;
  }

  static String? validateAddress(String? address) {
    if (address == null || address.trim().isEmpty) {
      return AppStrings.storeAddressRequired;
    }
    return null;
  }

  static String? validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return AppStrings.storePhoneRequired;
    }
    return null;
  }

  static String? validateReceiptFooter(String? footer) {
    if (footer == null || footer.trim().isEmpty) {
      return AppStrings.storeReceiptFooterRequired;
    }
    return null;
  }
}

