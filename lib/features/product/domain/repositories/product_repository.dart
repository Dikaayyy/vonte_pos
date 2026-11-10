import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({
    int? categoryId,
    String? query,
    bool includeDeleted = false,
  });

  Future<Product?> getProductById(int id);

  Future<Product> createProduct({
    required String name,
    int? categoryId,
    required int price,
    required int stock,
    String? photoPath,
    List<int> addonIds = const [],
  });

  Future<Product> updateProduct({
    required int id,
    required String name,
    int? categoryId,
    required int price,
    required int stock,
    String? photoPath,
    List<int> addonIds = const [],
  });

  Future<void> deleteProduct(int id);
}

