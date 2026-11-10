import '../../../../core/constants/app_strings.dart';

abstract final class AuthValidator {
  /// Validates that name is not empty.
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return AppStrings.nameRequired;
    }
    return null;
  }

  /// Validates that username has at least 3 characters and contains no whitespace.
  static String? validateUsername(String? username) {
    if (username == null || username.trim().length < 3) {
      return AppStrings.usernameMinLength;
    }
    if (username.contains(RegExp(r'\s'))) {
      return AppStrings.usernameNoSpaces;
    }
    return null;
  }

  /// Validates that password has at least 6 characters.
  static String? validatePassword(String? password) {
    if (password == null || password.length < 6) {
      return AppStrings.passwordMinLength;
    }
    return null;
  }
}

