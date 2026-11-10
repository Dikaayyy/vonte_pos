import 'package:sqflite/sqflite.dart' as sqflite;

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/addon.dart';
import '../../domain/repositories/addon_repository.dart';
import '../../domain/validators/addon_validator.dart';
import '../datasources/addon_local_data_source.dart';

class AddonRepositoryImpl implements AddonRepository {
  final AddonLocalDataSource _localDataSource;

  AddonRepositoryImpl(this._localDataSource);

  @override
  Future<List<Addon>> getAddons({bool includeDeleted = false}) async {
    return _localDataSource.getAddons(includeDeleted: includeDeleted);
  }

  @override
  Future<Addon?> getAddonById(int id) async {
    return _localDataSource.getAddonById(id);
  }

  @override
  Future<Addon> createAddon({
    required String name,
    required int price,
    required int stock,
  }) async {
    final nameError = AddonValidator.validateName(name);
    if (nameError != null) {
      throw ValidationException(nameError);
    }

    final priceError = AddonValidator.validatePrice(price);
    if (priceError != null) {
      throw ValidationException(priceError);
    }

    final stockError = AddonValidator.validateStock(stock);
    if (stockError != null) {
      throw ValidationException(stockError);
    }

    try {
      return await _localDataSource.createAddon(
        name: AddonValidator.normalizeName(name),
        price: price,
        stock: stock,
      );
    } on sqflite.DatabaseException catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<Addon> updateAddon({
    required int id,
    required String name,
    required int price,
    required int stock,
  }) async {
    final nameError = AddonValidator.validateName(name);
    if (nameError != null) {
      throw ValidationException(nameError);
    }

    final priceError = AddonValidator.validatePrice(price);
    if (priceError != null) {
      throw ValidationException(priceError);
    }

    final stockError = AddonValidator.validateStock(stock);
    if (stockError != null) {
      throw ValidationException(stockError);
    }

    try {
      return await _localDataSource.updateAddon(
        id: id,
        name: AddonValidator.normalizeName(name),
        price: price,
        stock: stock,
      );
    } on sqflite.DatabaseException catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<void> deleteAddon(int id) async {
    try {
      await _localDataSource.deleteAddon(id);
    } on sqflite.DatabaseException catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }
}

