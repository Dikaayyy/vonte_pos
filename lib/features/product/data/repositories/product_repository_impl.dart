import 'package:sqflite/sqflite.dart' as sqflite;

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/validators/product_validator.dart';
import '../datasources/product_local_data_source.dart';
import '../services/photo_storage.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource _localDataSource;
  final PhotoStorage _photoStorage;

  ProductRepositoryImpl(
    this._localDataSource,
    this._photoStorage,
  );

  @override
  Future<List<Product>> getProducts({
    int? categoryId,
    String? query,
    bool includeDeleted = false,
  }) async {
    return _localDataSource.getProducts(
      categoryId: categoryId,
      query: query,
      includeDeleted: includeDeleted,
    );
  }

  @override
  Future<Product?> getProductById(int id) async {
    return _localDataSource.getProductById(id);
  }

  @override
  Future<Product> createProduct({
    required String name,
    int? categoryId,
    required int price,
    required int stock,
    String? photoPath,
    List<int> addonIds = const [],
  }) async {
    final nameError = ProductValidator.validateName(name);
    if (nameError != null) {
      throw ValidationException(nameError);
    }

    final priceError = ProductValidator.validatePrice(price.toString());
    if (priceError != null) {
      throw ValidationException(priceError);
    }

    final stockError = ProductValidator.validateStock(stock.toString());
    if (stockError != null) {
      throw ValidationException(stockError);
    }

    try {
      return await _localDataSource.createProduct(
        name: name.trim(),
        categoryId: categoryId,
        price: price,
        stock: stock,
        photoPath: photoPath,
        addonIds: addonIds,
      );
    } on sqflite.DatabaseException catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<Product> updateProduct({
    required int id,
    required String name,
    int? categoryId,
    required int price,
    required int stock,
    String? photoPath,
    List<int> addonIds = const [],
  }) async {
    final nameError = ProductValidator.validateName(name);
    if (nameError != null) {
      throw ValidationException(nameError);
    }

    final priceError = ProductValidator.validatePrice(price.toString());
    if (priceError != null) {
      throw ValidationException(priceError);
    }

    final stockError = ProductValidator.validateStock(stock.toString());
    if (stockError != null) {
      throw ValidationException(stockError);
    }

    try {
      final existing = await _localDataSource.getProductById(id);
      if (existing != null &&
          existing.photoPath != null &&
          existing.photoPath != photoPath) {
        await _photoStorage.deletePhoto(existing.photoPath);
      }

      return await _localDataSource.updateProduct(
        id: id,
        name: name.trim(),
        categoryId: categoryId,
        price: price,
        stock: stock,
        photoPath: photoPath,
        addonIds: addonIds,
      );
    } on sqflite.DatabaseException catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      await _localDataSource.deleteProduct(id);
    } on sqflite.DatabaseException catch (e) {
      throw AppDatabaseException(e.toString());
    }
  }
}

