import '../entities/addon.dart';
import '../repositories/addon_repository.dart';

class GetAddonById {
  final AddonRepository _repository;

  const GetAddonById(this._repository);

  Future<Addon?> call(int id) {
    return _repository.getAddonById(id);
  }
}

