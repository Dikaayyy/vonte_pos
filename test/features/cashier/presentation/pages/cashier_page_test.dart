import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vonte_pos/core/constants/app_routes.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/core/theme/app_theme.dart';
import 'package:vonte_pos/core/utils/format_rupiah.dart';
import 'package:vonte_pos/features/addon/domain/entities/addon.dart';
import 'package:vonte_pos/features/addon/presentation/cubit/addon_cubit.dart';
import 'package:vonte_pos/features/addon/presentation/cubit/addon_state.dart';
import 'package:vonte_pos/features/cashier/domain/entities/cart_line.dart';
import 'package:vonte_pos/features/cashier/domain/entities/cart_totals.dart';
import 'package:vonte_pos/features/cashier/presentation/cubit/cart_cubit.dart';
import 'package:vonte_pos/features/cashier/presentation/cubit/cart_state.dart';
import 'package:vonte_pos/features/cashier/presentation/pages/cashier_view.dart';
import 'package:vonte_pos/features/cashier/presentation/pages/checkout_placeholder_page.dart';
import 'package:vonte_pos/features/cashier/presentation/widgets/cashier_addon_sheet.dart';
import 'package:vonte_pos/features/cashier/presentation/widgets/cashier_cart_view.dart';
import 'package:vonte_pos/features/category/domain/entities/category.dart';
import 'package:vonte_pos/features/category/presentation/cubit/category_cubit.dart';
import 'package:vonte_pos/features/category/presentation/cubit/category_state.dart';
import 'package:vonte_pos/features/product/data/services/photo_storage.dart';
import 'package:vonte_pos/features/product/domain/entities/product.dart';
import 'package:vonte_pos/features/product/presentation/cubit/product_cubit.dart';
import 'package:vonte_pos/features/product/presentation/cubit/product_state.dart';

class MockProductCubit extends Mock implements ProductCubit {}

class MockCategoryCubit extends Mock implements CategoryCubit {}

class MockAddonCubit extends Mock implements AddonCubit {}

class MockCartCubit extends Mock implements CartCubit {}

class MockPhotoStorage extends Mock implements PhotoStorage {}

void main() {
  late MockProductCubit mockProductCubit;
  late MockCategoryCubit mockCategoryCubit;
  late MockAddonCubit mockAddonCubit;
  late MockCartCubit mockCartCubit;
  late MockPhotoStorage mockPhotoStorage;

  const sampleCategories = [
    Category(id: 1, name: 'Minuman Kopi', productCount: 2),
    Category(id: 2, name: 'Makanan Ringan', productCount: 1),
  ];

  const sampleAddons = [
    Addon(id: 1, name: 'Extra Shot', price: 4000, stock: 10),
    Addon(id: 2, name: 'Oat Milk', price: 6000, stock: 5),
  ];

  const productPlain = Product(
    id: 1,
    categoryId: 1,
    categoryName: 'Minuman Kopi',
    name: 'Kopi Hitam',
    price: 15000,
    stock: 10,
    photoPath: null,
    addonIds: [], // no addons
    createdAt: 1000,
    updatedAt: 1000,
  );

  const productWithAddon = Product(
    id: 2,
    categoryId: 1,
    categoryName: 'Minuman Kopi',
    name: 'Kopi Susu Aren',
    price: 18000,
    stock: 20,
    photoPath: null,
    addonIds: [1, 2], // has addons
    createdAt: 1000,
    updatedAt: 1000,
  );

  const productLowStock = Product(
    id: 3,
    categoryId: 1,
    categoryName: 'Minuman Kopi',
    name: 'Espresso Single',
    price: 12000,
    stock: 3, // Low stock: <= 5
    photoPath: null,
    addonIds: [],
    createdAt: 1000,
    updatedAt: 1000,
  );

  const productOutOfStock = Product(
    id: 4,
    categoryId: 2,
    categoryName: 'Makanan Ringan',
    name: 'Croissant Cokelat',
    price: 25000,
    stock: 0, // Out of stock
    photoPath: null,
    addonIds: [],
    createdAt: 1000,
    updatedAt: 1000,
  );

  const productLimitedStock = Product(
    id: 5,
    categoryId: 1,
    categoryName: 'Minuman Kopi',
    name: 'Matcha Latte',
    price: 22000,
    stock: 2, // limited to 2
    photoPath: null,
    addonIds: [],
    createdAt: 1000,
    updatedAt: 1000,
  );

  setUpAll(() {
    registerFallbackValue(productPlain);
    registerFallbackValue(productWithAddon);
    registerFallbackValue(sampleAddons);
    registerFallbackValue(
      CartLine(
        productId: 1,
        productName: 'Kopi Hitam',
        unitPrice: 15000,
        qty: 1,
      ),
    );
  });

  setUp(() {
    mockProductCubit = MockProductCubit();
    mockCategoryCubit = MockCategoryCubit();
    mockAddonCubit = MockAddonCubit();
    mockCartCubit = MockCartCubit();
    mockPhotoStorage = MockPhotoStorage();

    when(() => mockProductCubit.state).thenReturn(
      const ProductState(
        status: ProductStatus.success,
        products: [
          productPlain,
          productWithAddon,
          productLowStock,
          productOutOfStock,
          productLimitedStock,
        ],
      ),
    );
    when(() => mockProductCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockProductCubit.search(any())).thenReturn(null);
    when(() => mockProductCubit.filterByCategory(any())).thenReturn(null);

    when(() => mockCategoryCubit.state).thenReturn(
      const CategoryState(
        status: CategoryStatus.success,
        categories: sampleCategories,
      ),
    );
    when(() => mockCategoryCubit.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockAddonCubit.state).thenReturn(
      const AddonState(
        status: AddonStatus.success,
        addons: sampleAddons,
      ),
    );
    when(() => mockAddonCubit.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockCartCubit.state).thenReturn(const CartState());
    when(() => mockCartCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCartCubit.addProduct(
          any(),
          addons: any(named: 'addons'),
          qty: any(named: 'qty'),
        )).thenAnswer((_) async {});
    when(() => mockCartCubit.addProductWithAddons(
          any(),
          any(),
          qty: any(named: 'qty'),
        )).thenAnswer((_) async {});
    when(() => mockCartCubit.updateQuantity(any(), any()))
        .thenAnswer((_) async {});
    when(() => mockCartCubit.removeLine(any())).thenReturn(null);
    when(() => mockCartCubit.clearError()).thenReturn(null);
  });

  Widget buildTestWidget({
    Size size = const Size(400, 800),
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductCubit>.value(value: mockProductCubit),
        BlocProvider<CategoryCubit>.value(value: mockCategoryCubit),
        BlocProvider<AddonCubit>.value(value: mockAddonCubit),
        BlocProvider<CartCubit>.value(value: mockCartCubit),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        routes: {
          AppRoutes.checkout: (_) => const CheckoutPlaceholderPage(),
        },
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: CashierView(photoStorage: mockPhotoStorage),
        ),
      ),
    );
  }

  group('Cashier Responsive Grid & Layout Breakpoints', () {
    testWidgets('layout pada lebar 400dp: 2 kolom grid dan sticky summary bar aktif',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(size: const Size(400, 800)));
      await tester.pumpAndSettle();

      // Verify grid crossAxisCount is 2
      final gridView = tester.widget<GridView>(find.byType(GridView));
      final gridDelegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(gridDelegate.crossAxisCount, 2);

      // Sticky summary bar is present
      expect(find.byKey(const Key('cashier_summary_bar')), findsOneWidget);

      // Fixed right cart panel is NOT present (no Row with cart panel)
      expect(find.byType(VerticalDivider), findsNothing);
    });

    testWidgets('layout pada lebar 900dp (expanded >= 840dp): 4 kolom grid dan fixed cart panel di kanan',
        (tester) async {
      tester.view.physicalSize = const Size(900, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(size: const Size(900, 800)));
      await tester.pumpAndSettle();

      // Verify grid crossAxisCount is 4
      final gridView = tester.widget<GridView>(find.byType(GridView));
      final gridDelegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(gridDelegate.crossAxisCount, 4);

      // Fixed cart panel is present on the right
      expect(find.byType(CashierCartView), findsOneWidget);
      expect(find.byType(VerticalDivider), findsOneWidget);

      // Sticky summary bar is NOT present in expanded mode
      expect(find.byKey(const Key('cashier_summary_bar')), findsNothing);
    });
  });

  group('Cashier Product Card States & Stock Constraints', () {
    testWidgets('kartu habis (stock 0) berbadge Habis dan tidak bisa di-tap',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Card for product 4 (Croissant Cokelat - stock 0)
      final outOfStockCard =
          find.byKey(const Key('cashier_product_card_4'));
      expect(outOfStockCard, findsOneWidget);

      // Displays "Habis" badge
      expect(
        find.descendant(
          of: outOfStockCard,
          matching: find.text(AppStrings.outOfStockBadge),
        ),
        findsOneWidget,
      );

      // Tap on card should NOT invoke addProduct
      await tester.tap(outOfStockCard);
      await tester.pump();

      verifyNever(() => mockCartCubit.addProduct(productOutOfStock,
          addons: any(named: 'addons'), qty: any(named: 'qty')));
    });

    testWidgets('kartu stok sudah penuh di keranjang berbadge "Stok sudah di keranjang" dan tidak bisa di-tap',
        (tester) async {
      // productLimitedStock has stock 2. Cart holds 2 units of it.
      when(() => mockCartCubit.state).thenReturn(
        CartState(
          items: [
            CartLine(
              productId: productLimitedStock.id,
              productName: productLimitedStock.name,
              unitPrice: productLimitedStock.price,
              qty: 2, // fully consumed stock
            ),
          ],
          totals: const CartTotals(
            subtotal: 44000,
            discountAmount: 0,
            total: 44000,
          ),
        ),
      );

      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final fullCard = find.byKey(const Key('cashier_product_card_5'));
      expect(fullCard, findsOneWidget);

      // Displays "Stok sudah di keranjang"
      expect(
        find.descendant(
          of: fullCard,
          matching: find.text(AppStrings.stockAlreadyInCart),
        ),
        findsWidgets,
      );

      // Tap is blocked
      await tester.tap(fullCard, warnIfMissed: false);
      await tester.pump();

      verifyNever(() => mockCartCubit.addProduct(productLimitedStock,
          addons: any(named: 'addons'), qty: any(named: 'qty')));
    });

    testWidgets('kartu stok menipis (<= 5) menampilkan badge peringatan "Sisa X"',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final lowStockCard = find.byKey(const Key('cashier_product_card_3'));
      expect(lowStockCard, findsOneWidget);

      expect(
        find.descendant(
          of: lowStockCard,
          matching: find.text('${AppStrings.lowStockPrefix} 3'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('tap produk tanpa add-on langsung menambah 1 unit',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final plainCard = find.byKey(const Key('cashier_product_card_1'));
      await tester.tap(plainCard);
      await tester.pump();

      verify(() => mockCartCubit.addProduct(productPlain, qty: 1)).called(1);
    });

    testWidgets('tap produk dengan add-on membuka CashierAddonSheet dan menambah ke keranjang',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Card 2 has addons
      final addonCard = find.byKey(const Key('cashier_product_card_2'));
      await tester.tap(addonCard);
      await tester.pumpAndSettle();

      // Sheet is open
      expect(find.byType(CashierAddonSheet), findsOneWidget);
      expect(find.text(AppStrings.selectAddonPrompt), findsOneWidget);
      expect(find.text('Extra Shot'), findsOneWidget);
      expect(find.text('Oat Milk'), findsOneWidget);

      // Select an add-on
      await tester.tap(find.text('Extra Shot'));
      await tester.pumpAndSettle();

      // Tap Tambah ke keranjang
      await tester.tap(find.text(AppStrings.addToCart));
      await tester.pumpAndSettle();

      verify(() => mockCartCubit.addProductWithAddons(
            productWithAddon,
            any(),
            qty: 1,
          )).called(1);
    });
  });

  group('Cashier Search & Category Filtering', () {
    testWidgets('mengetik pada kolom pencarian memanggil ProductCubit.search',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Kopi');
      await tester.pump();

      verify(() => mockProductCubit.search('Kopi')).called(1);
    });

    testWidgets('menekan chip kategori memanggil filterByCategory dan Semua mereset filter',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap Category 1 (Minuman Kopi)
      final cat1Chip = find.byKey(const Key('category_chip_1'));
      expect(cat1Chip, findsOneWidget);
      await tester.tap(cat1Chip);
      await tester.pump();

      verify(() => mockProductCubit.filterByCategory(1)).called(1);

      // Tap Semua
      final allChip = find.byKey(const Key('category_chip_all'));
      expect(allChip, findsOneWidget);
      await tester.tap(allChip);
      await tester.pump();

      verify(() => mockProductCubit.filterByCategory(null)).called(1);
    });
  });

  group('Inline Stock Error & Cart Operations', () {
    testWidgets('pesan stok tampil inline saat cartState memiliki error',
        (tester) async {
      const errorMsg = 'Stok Kopi Hitam tidak cukup. Tersisa 2.';
      when(() => mockCartCubit.state).thenReturn(
        const CartState(errorMessage: errorMsg),
      );

      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Inline error is visible
      expect(find.text(errorMsg), findsOneWidget);

      // Tap close button on error
      final closeErrorBtn = find.descendant(
        of: find.byType(CashierView),
        matching: find.byIcon(Icons.close_rounded),
      );
      if (closeErrorBtn.evaluate().isNotEmpty) {
        await tester.tap(closeErrorBtn.first);
        await tester.pump();
        verify(() => mockCartCubit.clearError()).called(1);
      }
    });

    testWidgets('keranjang menampilkan baris pesanan, stepper, total per baris rata kanan, dan tombol Bayar membuka checkout',
        (tester) async {
      final cartLine = CartLine(
        productId: productWithAddon.id,
        productName: productWithAddon.name,
        unitPrice: productWithAddon.price,
        qty: 1,
        addons: [
          CartAddon(id: 1, name: 'Extra Shot', price: 4000),
        ],
      );

      when(() => mockCartCubit.state).thenReturn(
        CartState(
          items: [cartLine],
          totals: const CartTotals(
            subtotal: 22000,
            discountAmount: 0,
            total: 22000,
          ),
        ),
      );

      // Test on 900dp (expanded) where cart panel is directly visible
      tester.view.physicalSize = const Size(900, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(size: const Size(900, 800)));
      await tester.pumpAndSettle();

      // 1. Line content verified
      expect(find.text('Kopi Susu Aren'), findsWidgets);
      expect(find.text('+ Extra Shot'), findsOneWidget);
      expect(find.text(formatRupiah(22000)), findsWidgets);

      // 2. Qty stepper increment
      final plusBtn = find.descendant(
        of: find.byType(CashierCartView),
        matching: find.byIcon(Icons.add_rounded),
      );
      await tester.tap(plusBtn.first);
      await tester.pump();

      verify(() => mockCartCubit.updateQuantity(cartLine, 2)).called(1);

      // 3. Delete row button
      final deleteBtn = find.descendant(
        of: find.byType(CashierCartView),
        matching: find.byIcon(Icons.delete_outline_rounded),
      );
      await tester.tap(deleteBtn.first);
      await tester.pump();

      verify(() => mockCartCubit.removeLine(cartLine)).called(1);

      // 4. Tap Bayar navigates to checkout placeholder
      final payBtn = find.widgetWithText(ElevatedButton, AppStrings.pay);
      await tester.tap(payBtn);
      await tester.pumpAndSettle();

      expect(find.byType(CheckoutPlaceholderPage), findsOneWidget);
      expect(find.text(AppStrings.checkoutTitle), findsWidgets);
    });
  });
}
