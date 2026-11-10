import '../entities/store_profile.dart';

abstract class StoreProfileRepository {
  Future<StoreProfile> getStoreProfile();

  Future<StoreProfile> updateStoreProfile(StoreProfile profile);

  Future<bool> seedSampleData();
}

