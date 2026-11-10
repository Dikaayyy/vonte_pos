import '../repositories/store_profile_repository.dart';

class SeedSampleData {
  final StoreProfileRepository _repository;

  const SeedSampleData(this._repository);

  Future<bool> call() {
    return _repository.seedSampleData();
  }
}

