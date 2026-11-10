import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/password_hasher.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._localDataSource);

  @override
  Future<User> register({
    required String name,
    required String username,
    required String password,
  }) async {
    // 1. Check if username is already taken (case-insensitive)
    final existingUser = await _localDataSource.getUserByUsername(username);
    if (existingUser != null) {
      throw const AuthException(AppStrings.usernameAlreadyTaken);
    }

    // 2. Generate random cryptographic salt and compute SHA-256 hash
    final salt = PasswordHasher.generateSalt();
    final passwordHash = PasswordHasher.hashPassword(password, salt);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    try {
      // 3. Create user in database
      final user = await _localDataSource.createUser(
        name: name,
        username: username,
        passwordHash: passwordHash,
        salt: salt,
        createdAt: now,
      );

      // 4. Create active session row
      await _localDataSource.createSession(
        userId: user.id,
        loggedInAt: now,
      );

      return user;
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw const AuthException(AppStrings.usernameAlreadyTaken);
      }
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<User> login({
    required String username,
    required String password,
  }) async {
    // 1. Lookup user by username (case-insensitive)
    final user = await _localDataSource.getUserByUsername(username);
    if (user == null || user.passwordHash == null || user.salt == null) {
      throw const AuthException(AppStrings.invalidCredentials);
    }

    // 2. Verify password hash using stored salt
    final isValid = PasswordHasher.verifyPassword(
      password: password,
      salt: user.salt!,
      expectedHash: user.passwordHash!,
    );

    if (!isValid) {
      throw const AuthException(AppStrings.invalidCredentials);
    }

    // 3. Create active session row
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _localDataSource.createSession(
      userId: user.id,
      loggedInAt: now,
    );

    return user;
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clearSession();
  }

  @override
  Future<Session?> getCurrentSession() async {
    return _localDataSource.getCurrentSession();
  }
}
