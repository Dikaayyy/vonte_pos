import '../../../../core/error/exceptions.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../validators/auth_validator.dart';

class RegisterUser {
  final AuthRepository _repository;

  const RegisterUser(this._repository);

  Future<User> call({
    required String name,
    required String username,
    required String password,
  }) async {
    final nameError = AuthValidator.validateName(name);
    if (nameError != null) {
      throw ValidationException(nameError);
    }

    final usernameError = AuthValidator.validateUsername(username);
    if (usernameError != null) {
      throw ValidationException(usernameError);
    }

    final passwordError = AuthValidator.validatePassword(password);
    if (passwordError != null) {
      throw ValidationException(passwordError);
    }

    return _repository.register(
      name: name.trim(),
      username: username.trim(),
      password: password,
    );
  }
}

