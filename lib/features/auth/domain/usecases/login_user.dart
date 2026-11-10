import '../../../../core/error/exceptions.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../validators/auth_validator.dart';

class LoginUser {
  final AuthRepository _repository;

  const LoginUser(this._repository);

  Future<User> call({
    required String username,
    required String password,
  }) async {
    final usernameError = AuthValidator.validateUsername(username);
    if (usernameError != null) {
      throw ValidationException(usernameError);
    }

    final passwordError = AuthValidator.validatePassword(password);
    if (passwordError != null) {
      throw ValidationException(passwordError);
    }

    return _repository.login(
      username: username.trim(),
      password: password,
    );
  }
}

