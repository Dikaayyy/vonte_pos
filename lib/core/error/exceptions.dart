class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class AppDatabaseException extends AppException {
  const AppDatabaseException(super.message);
}

class CheckoutException extends AppException {
  const CheckoutException(super.message);
}
