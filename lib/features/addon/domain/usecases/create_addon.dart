import '../entities/addon.dart';
import '../repositories/addon_repository.dart';

class CreateAddon {
  final AddonRepository _repository;

  const CreateAddon(this._repository);

  Future<Addon> call({
    required String name,
    required int price,
    required int stock,
  }) {
    return _repository.createAddon(
      name: name,
      price: price,
      stock: stock,
    );
  }
}

