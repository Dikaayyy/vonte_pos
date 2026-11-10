import '../entities/session.dart';
import '../repositories/auth_repository.dart';

class GetCurrentSession {
  final AuthRepository _repository;

  const GetCurrentSession(this._repository);

  Future<Session?> call() => _repository.getCurrentSession();
}

