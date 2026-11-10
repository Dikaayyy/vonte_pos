import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/core/utils/password_hasher.dart';

void main() {
  group('PasswordHasher', () {
    test('generateSalt returns non-empty base64 string of appropriate length', () {
      final salt1 = PasswordHasher.generateSalt();
      final salt2 = PasswordHasher.generateSalt();

      expect(salt1.isNotEmpty, isTrue);
      expect(salt2.isNotEmpty, isTrue);
      expect(salt1, isNot(equals(salt2)));
    });

    test('hashPassword produces identical hash for same password and salt', () {
      const password = 'SecretPassword123';
      const salt = 'random_salt_value';

      final hash1 = PasswordHasher.hashPassword(password, salt);
      final hash2 = PasswordHasher.hashPassword(password, salt);

      expect(hash1, equals(hash2));
      expect(hash1.length, equals(64)); // SHA-256 produces 64 hex characters
    });

    test('hashPassword produces different hash for different password or salt', () {
      const passwordA = 'PasswordA';
      const passwordB = 'PasswordB';
      const saltA = 'saltA';
      const saltB = 'saltB';

      expect(
        PasswordHasher.hashPassword(passwordA, saltA),
        isNot(equals(PasswordHasher.hashPassword(passwordB, saltA))),
      );

      expect(
        PasswordHasher.hashPassword(passwordA, saltA),
        isNot(equals(PasswordHasher.hashPassword(passwordA, saltB))),
      );
    });

    test('verifyPassword returns true for correct match and false for invalid', () {
      const password = 'MySecurePassword!';
      final salt = PasswordHasher.generateSalt();
      final hash = PasswordHasher.hashPassword(password, salt);

      expect(
        PasswordHasher.verifyPassword(
          password: password,
          salt: salt,
          expectedHash: hash,
        ),
        isTrue,
      );

      expect(
        PasswordHasher.verifyPassword(
          password: 'WrongPassword',
          salt: salt,
          expectedHash: hash,
        ),
        isFalse,
      );

      expect(
        PasswordHasher.verifyPassword(
          password: password,
          salt: 'different_salt',
          expectedHash: hash,
        ),
        isFalse,
      );
    });
  });
}

