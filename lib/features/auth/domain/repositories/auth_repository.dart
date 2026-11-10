import '../entities/session.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> register({
    required String name,
    required String username,
    required String password,
  });

  Future<User> login({
    required String username,
    required String password,
  });

  Future<void> logout();

  Future<Session?> getCurrentSession();
}

