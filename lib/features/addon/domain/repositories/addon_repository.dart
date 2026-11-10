import '../entities/addon.dart';

abstract class AddonRepository {
  /// Retrieves non-deleted addons (or all including deleted if [includeDeleted] is true).
  Future<List<Addon>> getAddons({bool includeDeleted = false});

  /// Retrieves an addon by id, regardless of soft delete state.
  Future<Addon?> getAddonById(int id);

  /// Creates a new addon with validated name, price (>= 0), and stock (>= 0).
  Future<Addon> createAddon({
    required String name,
    required int price,
    required int stock,
  });

  /// Updates an existing addon with validated name, price (>= 0), and stock (>= 0).
  Future<Addon> updateAddon({
    required int id,
    required String name,
    required int price,
    required int stock,
  });

  /// Soft deletes an addon (sets is_deleted = 1).
  Future<void> deleteAddon(int id);
}

