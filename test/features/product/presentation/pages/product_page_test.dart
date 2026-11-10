import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/core/theme/app_theme.dart';
import 'package:vonte_pos/features/addon/domain/entities/addon.dart';
import 'package:vonte_pos/features/addon/presentation/cubit/addon_cubit.dart';
import 'package:vonte_pos/features/addon/presentation/cubit/addon_state.dart';
import 'package:vonte_pos/features/category/domain/entities/category.dart';
import 'package:vonte_pos/features/category/presentation/cubit/category_cubit.dart';
import 'package:vonte_pos/features/category/presentation/cubit/category_state.dart';
import 'package:vonte_pos/features/product/data/services/photo_storage.dart';
import 'package:vonte_pos/features/product/domain/entities/product.dart';
import 'package:vonte_pos/features/product/presentation/cubit/product_cubit.dart';
import 'package:vonte_pos/features/product/presentation/cubit/product_state.dart';
import 'package:vonte_pos/features/product/presentation/pages/product_list_view.dart';
import 'package:vonte_pos/features/product/presentation/pages/product_shell_page.dart';
import 'package:vonte_pos/features/product/presentation/widgets/product_form_dialog.dart';

class MockProductCubit extends Mock implements ProductCubit {}

class MockCategoryCubit extends Mock implements CategoryCubit {}

class MockAddonCubit extends Mock implements AddonCubit {}

class MockPhotoStorage extends Mock implements PhotoStorage {}

void main() {
  late MockProductCubit mockProductCubit;
  late MockCategoryCubit mockCategoryCubit;
  late MockAddonCubit mockAddonCubit;
  late MockPhotoStorage mockPhotoStorage;

  const sampleCategories = [
    Category(id: 1, name: 'Minuman Kopi', productCount: 2),
    Category(id: 2, name: 'Makanan Ringan', productCount: 1),
  ];

  const sampleAddons = [
    Addon(id: 1, name: 'Extra Shot', price: 4000, stock: 10),
    Addon(id: 2, name: 'Oat Milk', price: 6000, stock: 5),
  ];

  const productNormal = Product(
    id: 1,
    categoryId: 1,
    categoryName: 'Minuman Kopi',
    name: 'Kopi Susu Aren',
    price: 18000,
    stock: 20,
    photoPath: 'product_images/aren.jpg',
    addonIds: [1, 2],
    createdAt: 1000,
    updatedAt: 1000,
  );

  const productLowStock = Product(
    id: 2,
    categoryId: 1,
    categoryName: 'Minuman Kopi',
    name: 'Espresso Single',
    price: 12000,
    stock: 3, // Low stock: <= 5
    photoPath: null, // Test placeholder
    addonIds: [],
    createdAt: 1000,
    updatedAt: 1000,
  );

  const productOutOfStock = Product(
    id: 3,
    categoryId: 2,
    categoryName: 'Makanan Ringan',
    name: 'Croissant Cokelat',
    price: 25000,
    stock: 0, // Out of stock
    photoPath: 'product_images/missing_croissant.jpg', // File missing simulation
    addonIds: [],
    createdAt: 1000,
    updatedAt: 1000,
  );

  setUp(() {
    mockProductCubit = MockProductCubit();
    mockCategoryCubit = MockCategoryCubit();
    mockAddonCubit = MockAddonCubit();
    mockPhotoStorage = MockPhotoStorage();

    when(() => mockProductCubit.state).thenReturn(
      const ProductState(
        status: ProductStatus.success,
        products: [productNormal, productLowStock, productOutOfStock],
      ),
    );
    when(() => mockProductCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockProductCubit.loadProducts(
          categoryId: any(named: 'categoryId'),
          query: any(named: 'query'),
          resetCategory: any(named: 'resetCategory'),
        )).thenAnswer((_) async {});
    when(() => mockProductCubit.filterByCategory(any())).thenAnswer((_) async {});
    when(() => mockProductCubit.search(any())).thenAnswer((_) async {});
    when(() => mockProductCubit.close()).thenAnswer((_) async {});

    when(() => mockCategoryCubit.state).thenReturn(
      const CategoryState(
        status: CategoryStatus.success,
        categories: sampleCategories,
      ),
    );
    when(() => mockCategoryCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCategoryCubit.loadCategories()).thenAnswer((_) async {});
    when(() => mockCategoryCubit.close()).thenAnswer((_) async {});

    when(() => mockAddonCubit.state).thenReturn(
      const AddonState(
        status: AddonStatus.success,
        addons: sampleAddons,
      ),
    );
    when(() => mockAddonCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAddonCubit.loadAddons()).thenAnswer((_) async {});
    when(() => mockAddonCubit.close()).thenAnswer((_) async {});

    // PhotoStorage: returns null for missing files safely
    when(() => mockPhotoStorage.getPhotoFile(any())).thenAnswer((_) async => null);
  });

  Widget buildTestWidget({required Widget child}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ProductCubit>.value(value: mockProductCubit),
          BlocProvider<CategoryCubit>.value(value: mockCategoryCubit),
          BlocProvider<AddonCubit>.value(value: mockAddonCubit),
        ],
        child: child,
      ),
    );
  }

  group('ProductListView Widget Tests', () {
    testWidgets('renders products with prices, stock, and semantic badges (low stock, out of stock)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: ProductListView(photoStorage: mockPhotoStorage),
        ),
      );
      await tester.pumpAndSettle();

      // Normal product
      expect(find.text('Kopi Susu Aren'), findsOneWidget);
      expect(find.text('Rp18.000'), findsOneWidget);
      expect(find.text('${AppStrings.stockLabelPrefix} 20'), findsOneWidget);
      expect(find.text('+2'), findsOneWidget); // 2 addons indicator

      // Low stock product: warning badge "Sisa 3"
      expect(find.text('Espresso Single'), findsOneWidget);
      expect(find.text('Rp12.000'), findsOneWidget);
      expect(find.text('Sisa 3'), findsOneWidget);

      // Out of stock product: error badge "Habis"
      expect(find.text('Croissant Cokelat'), findsOneWidget);
      expect(find.text('Rp25.000'), findsOneWidget);
      expect(find.text('Habis'), findsOneWidget);
    });

    testWidgets('missing photo safely renders first letter placeholder without crashing', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: ProductListView(photoStorage: mockPhotoStorage),
        ),
      );
      await tester.pumpAndSettle();

      // For 'Espresso Single' (photoPath null), placeholder 'E' is rendered
      expect(find.text('E'), findsWidgets);

      // For 'Croissant Cokelat' (missing file returning null), placeholder 'C' is rendered
      expect(find.text('C'), findsWidgets);
    });

    testWidgets('tapping category chip filters products', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: ProductListView(photoStorage: mockPhotoStorage),
        ),
      );
      await tester.pumpAndSettle();

      // Category chips: Semua, Minuman Kopi, Makanan Ringan
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Minuman Kopi'), findsWidgets);
      expect(find.text('Makanan Ringan'), findsWidgets);

      // Tap 'Minuman Kopi'
      await tester.tap(find.byKey(const Key('category_chip_1')));
      await tester.pumpAndSettle();

      verify(() => mockProductCubit.filterByCategory(1)).called(1);
    });

    testWidgets('typing into search field calls product cubit search', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: ProductListView(photoStorage: mockPhotoStorage),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'aren');
      await tester.pumpAndSettle();

      verify(() => mockProductCubit.search('aren')).called(1);
    });

    testWidgets('open add product dialog and validates empty/invalid inputs', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: ProductListView(photoStorage: mockPhotoStorage),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Tambah Produk button
      await tester.tap(find.text(AppStrings.addProduct).first);
      await tester.pumpAndSettle();

      // Dialog opens
      expect(find.text(AppStrings.productNameLabel), findsOneWidget);
      expect(find.text(AppStrings.productPriceLabel), findsOneWidget);
      expect(find.text(AppStrings.productStockLabel), findsOneWidget);

      // Tap Simpan with empty fields
      await tester.tap(find.text(AppStrings.save));
      await tester.pumpAndSettle();

      // Validations triggered
      expect(find.text(AppStrings.productNameRequired), findsOneWidget);
    });

    testWidgets('tapping product card with categoryId opens edit dialog without crashing', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: ProductListView(photoStorage: mockPhotoStorage),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on product card for 'Kopi Susu Aren' (which has categoryId: 1)
      await tester.tap(find.text('Kopi Susu Aren'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.editProduct), findsOneWidget);
    });

    testWidgets('edit dialog with unlisted categoryId falls back safely without assertion crash', (tester) async {
      const productWithUnlistedCat = Product(
        id: 99,
        categoryId: 999,
        categoryName: 'Kategori Lama',
        name: 'Produk Tanpa Kategori Cocok',
        price: 15000,
        stock: 10,
        photoPath: null,
        addonIds: [],
        createdAt: 1000,
        updatedAt: 1000,
      );

      when(() => mockProductCubit.state).thenReturn(
        const ProductState(
          status: ProductStatus.success,
          products: [productWithUnlistedCat],
        ),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: ProductListView(photoStorage: mockPhotoStorage),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Produk Tanpa Kategori Cocok'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.editProduct), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ProductFormDialog),
          matching: find.text('Kategori Lama'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('open delete dialog displays soft delete explanation and confirms', (tester) async {
      when(() => mockProductCubit.deleteProduct(1)).thenAnswer((_) async {});

      await tester.pumpWidget(
        buildTestWidget(
          child: ProductListView(photoStorage: mockPhotoStorage),
        ),
      );
      await tester.pumpAndSettle();

      // Tap delete on first card
      final deleteButtons = find.byTooltip(AppStrings.delete);
      expect(deleteButtons, findsWidgets);
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      // Confirmation dialog opens
      expect(find.text(AppStrings.deleteProductConfirmTitle), findsOneWidget);
      expect(find.text(AppStrings.deleteProductConfirmMessage), findsOneWidget);

      // Confirm delete
      await tester.tap(find.text(AppStrings.delete).last);
      await tester.pumpAndSettle();

      verify(() => mockProductCubit.deleteProduct(1)).called(1);
    });
  });

  group('ProductShellPage with Product Tab', () {
    testWidgets('ProductShellPage initial tab 0 renders ProductListView', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ProductShellPage(
            initialSubIndex: 0,
            productCubit: mockProductCubit,
            categoryCubit: mockCategoryCubit,
            addonCubit: mockAddonCubit,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.productListTitle), findsOneWidget);
      expect(find.text('Kopi Susu Aren'), findsOneWidget);
    });
  });
}
