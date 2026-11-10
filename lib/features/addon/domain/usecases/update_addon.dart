import '../entities/addon.dart';
import '../repositories/addon_repository.dart';

class UpdateAddon {
  final AddonRepository _repository;

  const UpdateAddon(this._repository);

  Future<Addon> call({
    required int id,
    required String name,
    required int price,
    required int stock,
  }) {
    return _repository.updateAddon(
      id: id,
      name: name,
      price: price,
      stock: stock,
    );
  }
}

