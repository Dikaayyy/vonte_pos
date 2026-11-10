import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/features/auth/domain/validators/auth_validator.dart';

void main() {
  group('AuthValidator Validation Rules', () {
    group('validateName', () {
      test('fails when name is null', () {
        expect(AuthValidator.validateName(null), equals(AppStrings.nameRequired));
      });

      test('fails when name is empty string', () {
        expect(AuthValidator.validateName(''), equals(AppStrings.nameRequired));
      });

      test('fails when name is only spaces', () {
        expect(AuthValidator.validateName('   '), equals(AppStrings.nameRequired));
      });

      test('passes for valid name', () {
        expect(AuthValidator.validateName('Budi Santoso'), isNull);
      });
    });

    group('validateUsername', () {
      test('fails when username is null', () {
        expect(
          AuthValidator.validateUsername(null),
          equals(AppStrings.usernameMinLength),
        );
      });

      test('fails when username is less than 3 characters', () {
        expect(
          AuthValidator.validateUsername('ab'),
          equals(AppStrings.usernameMinLength),
        );
        expect(
          AuthValidator.validateUsername('a'),
          equals(AppStrings.usernameMinLength),
        );
        expect(
          AuthValidator.validateUsername(''),
          equals(AppStrings.usernameMinLength),
        );
      });

      test('fails when username contains spaces or whitespace characters', () {
        expect(
          AuthValidator.validateUsername('kasir utama'),
          equals(AppStrings.usernameNoSpaces),
        );
        expect(
          AuthValidator.validateUsername(' kasir'),
          equals(AppStrings.usernameNoSpaces),
        );
        expect(
          AuthValidator.validateUsername('kasir '),
          equals(AppStrings.usernameNoSpaces),
        );
        expect(
          AuthValidator.validateUsername('ka\tsir'),
          equals(AppStrings.usernameNoSpaces),
        );
      });

      test('passes for valid username of 3 or more chars without space', () {
        expect(AuthValidator.validateUsername('adm'), isNull);
        expect(AuthValidator.validateUsername('admin_kasir'), isNull);
        expect(AuthValidator.validateUsername('kasir01'), isNull);
      });
    });

    group('validatePassword', () {
      test('fails when password is null', () {
        expect(
          AuthValidator.validatePassword(null),
          equals(AppStrings.passwordMinLength),
        );
      });

      test('fails when password is less than 6 characters', () {
        expect(
          AuthValidator.validatePassword('12345'),
          equals(AppStrings.passwordMinLength),
        );
        expect(
          AuthValidator.validatePassword(''),
          equals(AppStrings.passwordMinLength),
        );
      });

      test('passes when password has 6 or more characters', () {
        expect(AuthValidator.validatePassword('123456'), isNull);
        expect(AuthValidator.validatePassword('rahasia_aman'), isNull);
      });
    });
  });
}

