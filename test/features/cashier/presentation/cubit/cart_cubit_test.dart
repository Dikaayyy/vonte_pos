import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/features/addon/domain/entities/addon.dart';
import 'package:vonte_pos/features/addon/domain/usecases/get_addon_by_id.dart';
import 'package:vonte_pos/features/cashier/domain/entities/cart_line.dart';
import 'package:vonte_pos/features/cashier/domain/entities/cart_totals.dart';
import 'package:vonte_pos/features/cashier/domain/entities/discount.dart';
import 'package:vonte_pos/features/cashier/domain/validators/discount_calculator.dart';
import 'package:vonte_pos/features/cashier/domain/validators/stock_validator.dart';
import 'package:vonte_pos/features/cashier/presentation/cubit/cart_cubit.dart';
import 'package:vonte_pos/features/cashier/presentation/cubit/cart_state.dart';
import 'package:vonte_pos/features/product/domain/entities/product.dart';
import 'package:vonte_pos/features/product/domain/usecases/get_product_by_id.dart';

class MockGetProductById extends Mock implements GetProductById {}

class MockGetAddonById extends Mock implements GetAddonById {}

void main() {
  late MockGetProductById mockGetProductById;
  late MockGetAddonById mockGetAddonById;

  const productKopiSusu = Product(
    id: 10,
    name: 'Kopi Susu',
    price: 18000,
    stock: 2,
    createdAt: 1000,
    updatedAt: 1000,
  );

  const productCroissant = Product(
    id: 20,
    name: 'Croissant',
    price: 25000,
    stock: 10,
    createdAt: 1000,
    updatedAt: 1000,
  );

  const addonExtraShot = Addon(
    id: 1,
    name: 'Extra Shot',
    price: 3000,
    stock: 10,
  );

  const cartAddonExtraShot = CartAddon(
    id: 1,
    name: 'Extra Shot',
    price: 3000,
  );

  setUp(() {
    mockGetProductById = MockGetProductById();
    mockGetAddonById = MockGetAddonById();
  });

  CartCubit buildCubit() {
    return CartCubit(
      getProductById: mockGetProductById,
      getAddonById: mockGetAddonById,
      stockValidator: const StockValidator(),
      discountCalculator: const DiscountCalculator(),
    );
  }

  group('CartState', () {
    test('initial state has default empty values and correct helper getters', () {
      const state = CartState();
      expect(state.items, isEmpty);
      expect(state.lines, isEmpty);
      expect(state.discount, const Discount.none());
      expect(state.totals, const CartTotals.zero());
      expect(state.errorMessage, isNull);
      expect(state.isEmpty, isTrue);
      expect(state.isNotEmpty, isFalse);
      expect(state.itemCount, 0);
      expect(state.subtotal, 0);
      expect(state.discountAmount, 0);
      expect(state.total, 0);
      expect(state.hasError, isFalse);
    });

    test('copyWith updates state and clears error when requested', () {
      final line = CartLine(
        productId: 1,
        productName: 'Kopi',
        unitPrice: 10000,
        qty: 1,
      );
      var state = const CartState().copyWith(
        items: [line],
        errorMessage: 'Ada error',
      );
      expect(state.items.length, 1);
      expect(state.errorMessage, 'Ada error');
      expect(state.hasError, isTrue);

      state = state.copyWith(clearError: true);
      expect(state.errorMessage, isNull);
      expect(state.hasError, isFalse);
    });
  });

  group('CartCubit - addProduct', () {
    blocTest<CartCubit, CartState>(
      'tambah produk polos sukses menghitung subtotal dan total',
      build: () {
        when(() => mockGetProductById(20))
            .thenAnswer((_) async => productCroissant);
        return buildCubit();
      },
      act: (cubit) => cubit.addProduct(productCroissant),
      expect: () => [
        predicate<CartState>((state) {
          return state.items.length == 1 &&
              state.items.first.productId == 20 &&
              state.items.first.qty == 1 &&
              state.subtotal == 25000 &&
              state.total == 25000 &&
              state.errorMessage == null;
        }),
      ],
      verify: (_) {
        verify(() => mockGetProductById(20)).called(1);
      },
    );

    blocTest<CartCubit, CartState>(
      'tambah produk dengan add-on sukses menghitung harga unit snapshot dan total',
      build: () {
        when(() => mockGetProductById(20))
            .thenAnswer((_) async => productCroissant);
        when(() => mockGetAddonById(1))
            .thenAnswer((_) async => addonExtraShot);
        return buildCubit();
      },
      act: (cubit) => cubit.addProduct(
        productCroissant,
        addons: const [cartAddonExtraShot],
      ),
      expect: () => [
        predicate<CartState>((state) {
          final line = state.items.first;
          return state.items.length == 1 &&
              line.productId == 20 &&
              line.addons.length == 1 &&
              line.totalUnitPrice == 28000 &&
              state.subtotal == 28000 &&
              state.total == 28000 &&
              state.errorMessage == null;
        }),
      ],
    );

    blocTest<CartCubit, CartState>(
      'tambah produk dengan add-on via addProductWithAddons helper sukses',
      build: () {
        when(() => mockGetProductById(20))
            .thenAnswer((_) async => productCroissant);
        when(() => mockGetAddonById(1))
            .thenAnswer((_) async => addonExtraShot);
        return buildCubit();
      },
      act: (cubit) => cubit.addProductWithAddons(
        productCroissant,
        const [addonExtraShot],
      ),
      expect: () => [
        predicate<CartState>((state) {
          final line = state.items.first;
          return state.items.length == 1 &&
              line.addons.first.name == 'Extra Shot' &&
              state.subtotal == 28000;
        }),
      ],
    );

    blocTest<CartCubit, CartState>(
      'tambah kombinasi identik menambah qty baris yang sama (Rule 1 identity)',
      build: () {
        when(() => mockGetProductById(20))
            .thenAnswer((_) async => productCroissant);
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.addProduct(productCroissant);
        await cubit.addProduct(productCroissant);
      },
      expect: () => [
        predicate<CartState>((state) =>
            state.items.length == 1 &&
            state.items.first.qty == 1 &&
            state.subtotal == 25000),
        predicate<CartState>((state) =>
            state.items.length == 1 &&
            state.items.first.qty == 2 &&
            state.subtotal == 50000),
      ],
    );

    blocTest<CartCubit, CartState>(
      'tambah produk yang sama dengan add-on berbeda membuat baris baru (Rule 1 identity)',
      build: () {
        when(() => mockGetProductById(20))
            .thenAnswer((_) async => productCroissant);
        when(() => mockGetAddonById(1))
            .thenAnswer((_) async => addonExtraShot);
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.addProduct(productCroissant);
        await cubit.addProduct(
          productCroissant,
          addons: const [cartAddonExtraShot],
        );
      },
      expect: () => [
        predicate<CartState>((state) =>
            state.items.length == 1 && state.subtotal == 25000),
        predicate<CartState>((state) =>
            state.items.length == 2 &&
            state.items[0].addons.isEmpty &&
            state.items[1].addons.length == 1 &&
            state.subtotal == 53000),
      ],
    );

    blocTest<CartCubit, CartState>(
      'tambah produk dengan stok awal 0 ditolak dengan pesan habis',
      build: () {
        final outOfStockProduct = productKopiSusu.copyWith(stock: 0);
        when(() => mockGetProductById(10))
            .thenAnswer((_) async => outOfStockProduct);
        return buildCubit();
      },
      act: (cubit) => cubit.addProduct(productKopiSusu),
      expect: () => [
        predicate<CartState>((state) =>
            state.items.isEmpty &&
            state.errorMessage != null &&
            state.errorMessage!.contains('habis. Tersisa 0.')),
      ],
    );

    blocTest<CartCubit, CartState>(
      'tambah produk yang tidak ditemukan atau dihapus mengeluarkan pesan error',
      build: () {
        when(() => mockGetProductById(99)).thenAnswer((_) async => null);
        return buildCubit();
      },
      act: (cubit) => cubit.addProduct(
        const Product(
          id: 99,
          name: 'Produk Misterius',
          price: 10000,
          stock: 5,
          createdAt: 0,
          updatedAt: 0,
        ),
      ),
      expect: () => [
        predicate<CartState>((state) =>
            state.items.isEmpty &&
            state.errorMessage != null &&
            state.errorMessage!.contains('tidak ditemukan')),
      ],
    );

    blocTest<CartCubit, CartState>(
      'tambah produk dengan add-on yang stoknya habis ditolak',
      build: () {
        when(() => mockGetProductById(20))
            .thenAnswer((_) async => productCroissant);
        when(() => mockGetAddonById(1)).thenAnswer(
          (_) async => addonExtraShot.copyWith(stock: 0),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.addProduct(
        productCroissant,
        addons: const [cartAddonExtraShot],
      ),
      expect: () => [
        predicate<CartState>((state) =>
            state.items.isEmpty &&
            state.errorMessage != null &&
            state.errorMessage!.contains('Extra Shot habis. Tersisa 0.')),
      ],
    );
  });

  group('CartCubit - Rule 1 (Shared Stock Validation): Skenario Kopi Susu Stok 2', () {
    blocTest<CartCubit, CartState>(
      'Stok 2: 1x Kopi Susu polos + 1x Kopi Susu + Extra Shot = 2 unit terpakai; penambahan ketiga ditolak dan state items tidak berubah',
      build: () {
        when(() => mockGetProductById(10))
            .thenAnswer((_) async => productKopiSusu);
        when(() => mockGetAddonById(1))
            .thenAnswer((_) async => addonExtraShot);
        return buildCubit();
      },
      act: (cubit) async {
        // 1. Tambah 1x Kopi Susu polos (stok terpakai: 1)
        await cubit.addProduct(productKopiSusu);

        // 2. Tambah 1x Kopi Susu + Extra Shot (stok terpakai: 2, stok habis)
        await cubit.addProduct(
          productKopiSusu,
          addons: const [cartAddonExtraShot],
        );

        // 3. Coba tambah Kopi Susu ketiga (polos) -> Harus ditolak!
        await cubit.addProduct(productKopiSusu);
      },
      expect: () => [
        // Emisi 1: 1x Kopi Susu polos
        predicate<CartState>((state) =>
            state.items.length == 1 &&
            state.items[0].qty == 1 &&
            state.subtotal == 18000 &&
            state.errorMessage == null),
        // Emisi 2: 1x Kopi Susu polos + 1x Kopi Susu + Extra Shot
        predicate<CartState>((state) =>
            state.items.length == 2 &&
            state.items[0].qty == 1 &&
            state.items[1].qty == 1 &&
            state.subtotal == 39000 && // 18000 + (18000 + 3000)
            state.errorMessage == null),
        // Emisi 3: Penambahan ketiga ditolak; state items & totals tidak berubah, error berisi pesan stok
        predicate<CartState>((state) =>
            state.items.length == 2 &&
            state.items[0].qty == 1 &&
            state.items[1].qty == 1 &&
            state.subtotal == 39000 &&
            state.errorMessage == 'Stok tidak cukup. Tersisa 0.'),
      ],
    );

    blocTest<CartCubit, CartState>(
      'Stok 2: Coba langsung tambah qty 3 pada produk stok 2 ditolak dengan pesan sisa stok',
      build: () {
        when(() => mockGetProductById(10))
            .thenAnswer((_) async => productKopiSusu);
        return buildCubit();
      },
      act: (cubit) => cubit.addProduct(productKopiSusu, qty: 3),
      expect: () => [
        predicate<CartState>((state) =>
            state.items.isEmpty &&
            state.errorMessage == 'Stok tidak cukup. Tersisa 2.'),
      ],
    );
  });

  group('CartCubit - updateQuantity & updateQty', () {
    blocTest<CartCubit, CartState>(
      'menaikkan qty dalam batas stok berhasil memperbarui totals',
      build: () {
        when(() => mockGetProductById(20))
            .thenAnswer((_) async => productCroissant);
        return buildCubit();
      },
      seed: () {
        final line = CartLine(
          productId: 20,
          productName: 'Croissant',
          unitPrice: 25000,
          qty: 1,
        );
        return CartState(
          items: [line],
          totals: const CartTotals(
            subtotal: 25000,
            discountAmount: 0,
            total: 25000,
          ),
        );
      },
      act: (cubit) async {
        final line = cubit.state.items.first;
        await cubit.updateQuantity(line, 3);
      },
      expect: () => [
        predicate<CartState>((state) =>
            state.items.length == 1 &&
            state.items.first.qty == 3 &&
            state.subtotal == 75000 &&
            state.total == 75000 &&
            state.errorMessage == null),
      ],
    );

    blocTest<CartCubit, CartState>(
      'menaikkan qty melebihi batas stok ditolak dan mempertahankan items',
      build: () {
        when(() => mockGetProductById(10))
            .thenAnswer((_) async => productKopiSusu); // stok = 2
        return buildCubit();
      },
      seed: () {
        final line = CartLine(
          productId: 10,
          productName: 'Kopi Susu',
          unitPrice: 18000,
          qty: 1,
        );
        return CartState(
          items: [line],
          totals: const CartTotals(
            subtotal: 18000,
            discountAmount: 0,
            total: 18000,
          ),
        );
      },
      act: (cubit) async {
        final line = cubit.state.items.first;
        await cubit.updateQty(line, 5); // Melebihi stok 2
      },
      expect: () => [
        predicate<CartState>((state) =>
            state.items.length == 1 &&
            state.items.first.qty == 1 &&
            state.subtotal == 18000 &&
            state.errorMessage == 'Stok tidak cukup. Tersisa 1.'),
      ],
    );

    blocTest<CartCubit, CartState>(
      'menurunkan qty selalu diizinkan tanpa cek stok database',
      build: () => buildCubit(),
      seed: () {
        final line = CartLine(
          productId: 10,
          productName: 'Kopi Susu',
          unitPrice: 18000,
          qty: 4,
        );
        return CartState(
          items: [line],
          totals: const CartTotals(
            subtotal: 72000,
            discountAmount: 0,
            total: 72000,
          ),
        );
      },
      act: (cubit) async {
        final line = cubit.state.items.first;
        await cubit.updateQuantity(line, 2);
      },
      expect: () => [
        predicate<CartState>((state) =>
            state.items.length == 1 &&
            state.items.first.qty == 2 &&
            state.subtotal == 36000 &&
            state.total == 36000),
      ],
      verify: (_) {
        verifyNever(() => mockGetProductById(any()));
      },
    );

    blocTest<CartCubit, CartState>(
      'mengubah qty menjadi 0 menghapus baris dari keranjang',
      build: () => buildCubit(),
      seed: () {
        final line = CartLine(
          productId: 10,
          productName: 'Kopi Susu',
          unitPrice: 18000,
          qty: 1,
        );
        return CartState(
          items: [line],
          totals: const CartTotals(
            subtotal: 18000,
            discountAmount: 0,
            total: 18000,
          ),
        );
      },
      act: (cubit) async {
        final line = cubit.state.items.first;
        await cubit.updateQuantity(line, 0);
      },
      expect: () => [
        const CartState(),
      ],
    );
  });

  group('CartCubit - removeLine', () {
    blocTest<CartCubit, CartState>(
      'hapus baris memperbarui items dan menghitung ulang totals',
      build: () => buildCubit(),
      seed: () {
        final line1 = CartLine(
          productId: 10,
          productName: 'Kopi Susu',
          unitPrice: 18000,
          qty: 1,
        );
        final line2 = CartLine(
          productId: 20,
          productName: 'Croissant',
          unitPrice: 25000,
          qty: 1,
        );
        return CartState(
          items: [line1, line2],
          totals: const CartTotals(
            subtotal: 43000,
            discountAmount: 0,
            total: 43000,
          ),
        );
      },
      act: (cubit) {
        final lineToRemove = cubit.state.items.first;
        cubit.removeLine(lineToRemove);
      },
      expect: () => [
        predicate<CartState>((state) =>
            state.items.length == 1 &&
            state.items.first.productId == 20 &&
            state.subtotal == 25000 &&
            state.total == 25000),
      ],
    );

    blocTest<CartCubit, CartState>(
      'hapus seluruh baris mengembalikan state ke empty initial',
      build: () => buildCubit(),
      seed: () {
        final line = CartLine(
          productId: 10,
          productName: 'Kopi Susu',
          unitPrice: 18000,
          qty: 1,
        );
        return CartState(
          items: [line],
          discount: const Discount.fixed(5000),
          totals: const CartTotals(
            subtotal: 18000,
            discountAmount: 5000,
            total: 13000,
          ),
        );
      },
      act: (cubit) {
        cubit.removeLine(cubit.state.items.first);
      },
      expect: () => [
        const CartState(),
      ],
    );
  });

  group('CartCubit - setDiscount (Rule 4 Discount Protection)', () {
    blocTest<CartCubit, CartState>(
      'diskon persen valid (10%) berhasil diterapkan',
      build: () => buildCubit(),
      seed: () {
        final line = CartLine(
          productId: 20,
          productName: 'Croissant',
          unitPrice: 50000,
          qty: 1,
        );
        return CartState(
          items: [line],
          totals: const CartTotals(
            subtotal: 50000,
            discountAmount: 0,
            total: 50000,
          ),
        );
      },
      act: (cubit) => cubit.setDiscount(const Discount.percent(10)),
      expect: () => [
        predicate<CartState>((state) =>
            state.discount == const Discount.percent(10) &&
            state.discountAmount == 5000 &&
            state.total == 45000 &&
            state.errorMessage == null),
      ],
    );

    blocTest<CartCubit, CartState>(
      'diskon persen invalid (> 100%) ditolak dan mempertahankan diskon lama',
      build: () => buildCubit(),
      seed: () {
        final line = CartLine(
          productId: 20,
          productName: 'Croissant',
          unitPrice: 50000,
          qty: 1,
        );
        return CartState(
          items: [line],
          totals: const CartTotals(
            subtotal: 50000,
            discountAmount: 0,
            total: 50000,
          ),
        );
      },
      act: (cubit) => cubit.setDiscount(const Discount.percent(150)),
      expect: () => [
        predicate<CartState>((state) =>
            state.discount == const Discount.none() &&
            state.total == 50000 &&
            state.errorMessage == AppStrings.discountPercentOutOfRange),
      ],
    );

    blocTest<CartCubit, CartState>(
      'diskon nominal valid (10.000) berhasil diterapkan',
      build: () => buildCubit(),
      seed: () {
        final line = CartLine(
          productId: 20,
          productName: 'Croissant',
          unitPrice: 50000,
          qty: 1,
        );
        return CartState(
          items: [line],
          totals: const CartTotals(
            subtotal: 50000,
            discountAmount: 0,
            total: 50000,
          ),
        );
      },
      act: (cubit) => cubit.setDiscount(const Discount.fixed(10000)),
      expect: () => [
        predicate<CartState>((state) =>
            state.discount == const Discount.fixed(10000) &&
            state.discountAmount == 10000 &&
            state.total == 40000),
      ],
    );

    blocTest<CartCubit, CartState>(
      'diskon nominal melebihi subtotal ditolak',
      build: () => buildCubit(),
      seed: () {
        final line = CartLine(
          productId: 20,
          productName: 'Croissant',
          unitPrice: 50000,
          qty: 1,
        );
        return CartState(
          items: [line],
          totals: const CartTotals(
            subtotal: 50000,
            discountAmount: 0,
            total: 50000,
          ),
        );
      },
      act: (cubit) => cubit.setDiscount(const Discount.fixed(60000)),
      expect: () => [
        predicate<CartState>((state) =>
            state.discount == const Discount.none() &&
            state.total == 50000 &&
            state.errorMessage == AppStrings.discountFixedExceedsSubtotal),
      ],
    );
  });

  group('CartCubit - clearCart & clearError', () {
    blocTest<CartCubit, CartState>(
      'clearCart mengosongkan seluruh keranjang',
      build: () => buildCubit(),
      seed: () {
        final line = CartLine(
          productId: 10,
          productName: 'Kopi Susu',
          unitPrice: 18000,
          qty: 2,
        );
        return CartState(
          items: [line],
          discount: const Discount.percent(10),
          totals: const CartTotals(
            subtotal: 36000,
            discountAmount: 3600,
            total: 32400,
          ),
          errorMessage: 'Error lama',
        );
      },
      act: (cubit) => cubit.clearCart(),
      expect: () => [
        const CartState(),
      ],
    );

    blocTest<CartCubit, CartState>(
      'clearError membersihkan pesan error dari state',
      build: () => buildCubit(),
      seed: () {
        return const CartState(errorMessage: 'Ada pesan error');
      },
      act: (cubit) => cubit.clearError(),
      expect: () => [
        const CartState(errorMessage: null),
      ],
    );
  });

  group('CartCubit - Exception handling', () {
    blocTest<CartCubit, CartState>(
      'jika getProductById melempar exception, cubit menangkapnya dan mengeset errorMessage',
      build: () {
        when(() => mockGetProductById(10)).thenThrow(Exception('DB error'));
        return buildCubit();
      },
      act: (cubit) => cubit.addProduct(productKopiSusu),
      expect: () => [
        predicate<CartState>((state) =>
            state.items.isEmpty &&
            state.errorMessage == 'Gagal memuat data stok terbaru.'),
      ],
    );
  });
}
