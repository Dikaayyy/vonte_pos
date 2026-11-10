import '../entities/store_profile.dart';
import '../repositories/store_profile_repository.dart';

class GetStoreProfile {
  final StoreProfileRepository _repository;

  const GetStoreProfile(this._repository);

  Future<StoreProfile> call() {
    return _repository.getStoreProfile();
  }
}

