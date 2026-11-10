import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

abstract final class PasswordHasher {
  /// Generates a cryptographically secure random salt encoded in Base64URL.
  static String generateSalt([int length = 16]) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Calculates SHA-256 hash of salt + password.
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt$password');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifies whether the provided raw password matches the expected hash.
  static bool verifyPassword({
    required String password,
    required String salt,
    required String expectedHash,
  }) {
    final calculatedHash = hashPassword(password, salt);
    return calculatedHash == expectedHash;
  }
}

