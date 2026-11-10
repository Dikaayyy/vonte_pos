import '../entities/addon.dart';
import '../repositories/addon_repository.dart';

class GetAddons {
  final AddonRepository _repository;

  const GetAddons(this._repository);

  Future<List<Addon>> call({bool includeDeleted = false}) {
    return _repository.getAddons(includeDeleted: includeDeleted);
  }
}

