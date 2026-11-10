import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vonte_pos/core/error/exceptions.dart';
import 'package:vonte_pos/features/product/domain/entities/product.dart';
import 'package:vonte_pos/features/product/domain/usecases/create_product.dart';
import 'package:vonte_pos/features/product/domain/usecases/delete_product.dart';
import 'package:vonte_pos/features/product/domain/usecases/get_products.dart';
import 'package:vonte_pos/features/product/domain/usecases/update_product.dart';
import 'package:vonte_pos/features/product/presentation/cubit/product_cubit.dart';
import 'package:vonte_pos/features/product/presentation/cubit/product_state.dart';

class MockGetProducts extends Mock implements GetProducts {}

class MockCreateProduct extends Mock implements CreateProduct {}

class MockUpdateProduct extends Mock implements UpdateProduct {}

class MockDeleteProduct extends Mock implements DeleteProduct {}

void main() {
  late MockGetProducts mockGetProducts;
  late MockCreateProduct mockCreateProduct;
  late MockUpdateProduct mockUpdateProduct;
  late MockDeleteProduct mockDeleteProduct;
  late ProductCubit productCubit;

  const testProduct = Product(
    id: 1,
    categoryId: 1,
    categoryName: 'Kopi',
    name: 'Kopi Susu',
    price: 18000,
    stock: 10,
    photoPath: 'product_images/kopi.jpg',
    addonIds: [1, 2],
    createdAt: 1000,
    updatedAt: 1000,
  );

  setUp(() {
    mockGetProducts = MockGetProducts();
    mockCreateProduct = MockCreateProduct();
    mockUpdateProduct = MockUpdateProduct();
    mockDeleteProduct = MockDeleteProduct();

    productCubit = ProductCubit(
      getProductsUseCase: mockGetProducts,
      createProductUseCase: mockCreateProduct,
      updateProductUseCase: mockUpdateProduct,
      deleteProductUseCase: mockDeleteProduct,
    );
  });

  tearDown(() {
    productCubit.close();
  });

  group('ProductCubit', () {
    test('initial state has ProductStatus.initial and empty products', () {
      expect(productCubit.state, const ProductState());
    });

    blocTest<ProductCubit, ProductState>(
      'loadProducts emits [loading, success] when use case returns products',
      build: () {
        when(() => mockGetProducts(
              categoryId: any(named: 'categoryId'),
              query: any(named: 'query'),
            )).thenAnswer((_) async => [testProduct]);
        return productCubit;
      },
      act: (cubit) => cubit.loadProducts(),
      expect: () => [
        const ProductState(
          status: ProductStatus.loading,
          products: [],
        ),
        const ProductState(
          status: ProductStatus.success,
          products: [testProduct],
        ),
      ],
    );

    blocTest<ProductCubit, ProductState>(
      'loadProducts emits [loading, failure] when use case throws exception',
      build: () {
        when(() => mockGetProducts(
              categoryId: any(named: 'categoryId'),
              query: any(named: 'query'),
            )).thenThrow(const AppDatabaseException('Database error'));
        return productCubit;
      },
      act: (cubit) => cubit.loadProducts(),
      expect: () => [
        const ProductState(
          status: ProductStatus.loading,
          products: [],
        ),
        const ProductState(
          status: ProductStatus.failure,
          products: [],
          errorMessage: 'Database error',
        ),
      ],
    );

    blocTest<ProductCubit, ProductState>(
      'filterByCategory updates selectedCategoryId and reloads',
      build: () {
        when(() => mockGetProducts(
              categoryId: 1,
              query: any(named: 'query'),
            )).thenAnswer((_) async => [testProduct]);
        return productCubit;
      },
      act: (cubit) => cubit.filterByCategory(1),
      expect: () => [
        const ProductState(
          status: ProductStatus.loading,
          selectedCategoryId: 1,
        ),
        const ProductState(
          status: ProductStatus.success,
          selectedCategoryId: 1,
          products: [testProduct],
        ),
      ],
    );

    blocTest<ProductCubit, ProductState>(
      'search updates searchQuery and reloads',
      build: () {
        when(() => mockGetProducts(
              categoryId: any(named: 'categoryId'),
              query: 'susu',
            )).thenAnswer((_) async => [testProduct]);
        return productCubit;
      },
      act: (cubit) => cubit.search('susu'),
      expect: () => [
        const ProductState(
          status: ProductStatus.loading,
          searchQuery: 'susu',
        ),
        const ProductState(
          status: ProductStatus.success,
          searchQuery: 'susu',
          products: [testProduct],
        ),
      ],
    );

    blocTest<ProductCubit, ProductState>(
      'addProduct calls createProduct and reloads products',
      build: () {
        when(() => mockCreateProduct(
              name: 'Kopi Susu',
              categoryId: 1,
              price: 18000,
              stock: 10,
              photoPath: 'product_images/kopi.jpg',
              addonIds: [1, 2],
            )).thenAnswer((_) async => testProduct);
        when(() => mockGetProducts(
              categoryId: any(named: 'categoryId'),
              query: any(named: 'query'),
            )).thenAnswer((_) async => [testProduct]);
        return productCubit;
      },
      act: (cubit) => cubit.addProduct(
        name: 'Kopi Susu',
        categoryId: 1,
        price: 18000,
        stock: 10,
        photoPath: 'product_images/kopi.jpg',
        addonIds: [1, 2],
      ),
      expect: () => [
        const ProductState(status: ProductStatus.loading),
        const ProductState(
          status: ProductStatus.success,
          products: [testProduct],
        ),
      ],
    );

    blocTest<ProductCubit, ProductState>(
      'updateProduct calls updateProduct and reloads products',
      build: () {
        when(() => mockUpdateProduct(
              id: 1,
              name: 'Kopi Susu Ubah',
              categoryId: 1,
              price: 20000,
              stock: 8,
              photoPath: 'product_images/kopi.jpg',
              addonIds: [1],
            )).thenAnswer((_) async => testProduct);
        when(() => mockGetProducts(
              categoryId: any(named: 'categoryId'),
              query: any(named: 'query'),
            )).thenAnswer((_) async => [testProduct]);
        return productCubit;
      },
      act: (cubit) => cubit.updateProduct(
        id: 1,
        name: 'Kopi Susu Ubah',
        categoryId: 1,
        price: 20000,
        stock: 8,
        photoPath: 'product_images/kopi.jpg',
        addonIds: [1],
      ),
      expect: () => [
        const ProductState(status: ProductStatus.loading),
        const ProductState(
          status: ProductStatus.success,
          products: [testProduct],
        ),
      ],
    );

    blocTest<ProductCubit, ProductState>(
      'deleteProduct calls deleteProduct and reloads products',
      build: () {
        when(() => mockDeleteProduct(1)).thenAnswer((_) async {});
        when(() => mockGetProducts(
              categoryId: any(named: 'categoryId'),
              query: any(named: 'query'),
            )).thenAnswer((_) async => []);
        return productCubit;
      },
      act: (cubit) => cubit.deleteProduct(1),
      expect: () => [
        const ProductState(status: ProductStatus.loading),
        const ProductState(
          status: ProductStatus.success,
          products: [],
        ),
      ],
    );
  });
}

