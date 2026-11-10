import '../repositories/addon_repository.dart';

class DeleteAddon {
  final AddonRepository _repository;

  const DeleteAddon(this._repository);

  Future<void> call(int id) {
    return _repository.deleteAddon(id);
  }
}

