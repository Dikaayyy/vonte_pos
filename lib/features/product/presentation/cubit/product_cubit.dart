import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/update_product.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final GetProducts getProductsUseCase;
  final CreateProduct createProductUseCase;
  final UpdateProduct updateProductUseCase;
  final DeleteProduct deleteProductUseCase;

  ProductCubit({
    required this.getProductsUseCase,
    required this.createProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
  }) : super(const ProductState());

  Future<void> loadProducts({
    int? categoryId,
    String? query,
    bool resetCategory = false,
  }) async {
    final effectiveCategoryId =
        resetCategory ? null : (categoryId ?? state.selectedCategoryId);
    final effectiveQuery = query ?? state.searchQuery;

    emit(state.copyWith(
      status: ProductStatus.loading,
      selectedCategoryId: effectiveCategoryId,
      clearCategory: resetCategory || effectiveCategoryId == null,
      searchQuery: effectiveQuery,
      clearError: true,
    ));

    try {
      final products = await getProductsUseCase(
        categoryId: effectiveCategoryId,
        query: effectiveQuery,
      );
      emit(state.copyWith(
        status: ProductStatus.success,
        products: products,
        clearError: true,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: ProductStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void filterByCategory(int? categoryId) {
    loadProducts(categoryId: categoryId, resetCategory: categoryId == null);
  }

  void search(String query) {
    loadProducts(query: query);
  }

  Future<void> addProduct({
    required String name,
    int? categoryId,
    required int price,
    required int stock,
    String? photoPath,
    List<int> addonIds = const [],
  }) async {
    emit(state.copyWith(status: ProductStatus.loading, clearError: true));
    try {
      await createProductUseCase(
        name: name,
        categoryId: categoryId,
        price: price,
        stock: stock,
        photoPath: photoPath,
        addonIds: addonIds,
      );
      final products = await getProductsUseCase(
        categoryId: state.selectedCategoryId,
        query: state.searchQuery,
      );
      emit(state.copyWith(
        status: ProductStatus.success,
        products: products,
        clearError: true,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: ProductStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> updateProduct({
    required int id,
    required String name,
    int? categoryId,
    required int price,
    required int stock,
    String? photoPath,
    List<int> addonIds = const [],
  }) async {
    emit(state.copyWith(status: ProductStatus.loading, clearError: true));
    try {
      await updateProductUseCase(
        id: id,
        name: name,
        categoryId: categoryId,
        price: price,
        stock: stock,
        photoPath: photoPath,
        addonIds: addonIds,
      );
      final products = await getProductsUseCase(
        categoryId: state.selectedCategoryId,
        query: state.searchQuery,
      );
      emit(state.copyWith(
        status: ProductStatus.success,
        products: products,
        clearError: true,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: ProductStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> deleteProduct(int id) async {
    emit(state.copyWith(status: ProductStatus.loading, clearError: true));
    try {
      await deleteProductUseCase(id);
      final products = await getProductsUseCase(
        categoryId: state.selectedCategoryId,
        query: state.searchQuery,
      );
      emit(state.copyWith(
        status: ProductStatus.success,
        products: products,
        clearError: true,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: ProductStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}

