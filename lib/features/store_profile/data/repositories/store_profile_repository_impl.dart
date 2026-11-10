import '../../domain/entities/store_profile.dart';
import '../../domain/repositories/store_profile_repository.dart';
import '../datasources/store_profile_local_data_source.dart';
import '../models/store_profile_model.dart';

class StoreProfileRepositoryImpl implements StoreProfileRepository {
  final StoreProfileLocalDataSource _localDataSource;

  const StoreProfileRepositoryImpl(this._localDataSource);

  @override
  Future<StoreProfile> getStoreProfile() {
    return _localDataSource.getStoreProfile();
  }

  @override
  Future<StoreProfile> updateStoreProfile(StoreProfile profile) {
    final model = StoreProfileModel.fromEntity(profile);
    return _localDataSource.updateStoreProfile(model);
  }

  @override
  Future<bool> seedSampleData() {
    return _localDataSource.seedSampleData();
  }
}

