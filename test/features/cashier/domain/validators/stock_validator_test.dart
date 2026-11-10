import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/features/cashier/domain/entities/cart_line.dart';
import 'package:vonte_pos/features/cashier/domain/validators/stock_validator.dart';

void main() {
  const validator = StockValidator();

  const extraShot = CartAddon(id: 1, name: 'Extra Shot', price: 3000);
  const caramelSyrup = CartAddon(id: 2, name: 'Caramel Syrup', price: 4000);

  group('StockValidator - Rule 1 (Shared Stock Validation)', () {
    test(
        'Stok 2: 1x Kopi Susu polos + 1x Kopi Susu + Extra Shot memakai 2 unit; penambahan ketiga ditolak',
        () {
      // Setup cart with 1x plain Milk Coffee and 1x Milk Coffee with Extra Shot
      final line1 = CartLine(
        productId: 10,
        productName: 'Kopi Susu',
        unitPrice: 18000,
        qty: 1,
        addons: const [],
      );
      final line2 = CartLine(
        productId: 10,
        productName: 'Kopi Susu',
        unitPrice: 18000,
        qty: 1,
        addons: const [extraShot],
      );
      final cart = [line1, line2];

      // Product units consumed = 1 + 1 = 2
      final productUsage = validator.calculateProductUsage(cart, 10);
      expect(productUsage, 2);

      // Attempt to add a 3rd unit of Kopi Susu (plain or with addon) when available stock is 2
      final resultAddPlain = validator.validateAdd(
        currentCart: cart,
        productId: 10,
        productName: 'Kopi Susu',
        availableProductStock: 2,
        qtyToAdd: 1,
      );

      expect(resultAddPlain.isValid, isFalse);
      expect(resultAddPlain.remainingStock, 0);
      expect(resultAddPlain.message, contains('Tersisa 0'));
      expect(resultAddPlain.failedId, 10);
      expect(resultAddPlain.isAddon, isFalse);

      final resultAddWithAddon = validator.validateAdd(
        currentCart: cart,
        productId: 10,
        productName: 'Kopi Susu',
        availableProductStock: 2,
        qtyToAdd: 1,
        addons: const [extraShot],
        addonStocks: const {1: 10},
      );

      expect(resultAddWithAddon.isValid, isFalse);
      expect(resultAddWithAddon.remainingStock, 0);
    });

    test(
        'Stok add-on terakumulasi (Extra Shot stok 2; satu baris qty 2 dengan Extra Shot memakai 2; satu lagi ditolak)',
        () {
      // One cart line with qty 2, each cup has Extra Shot attached
      final line = CartLine(
        productId: 10,
        productName: 'Kopi Susu',
        unitPrice: 18000,
        qty: 2,
        addons: const [extraShot],
      );
      final cart = [line];

      // Addon usage = 2 * 1 = 2
      final addonUsage = validator.calculateAddonUsage(cart, extraShot.id);
      expect(addonUsage, 2);

      // Attempt to add another line with Extra Shot when Extra Shot stock is 2
      final result = validator.validateAdd(
        currentCart: cart,
        productId: 10,
        productName: 'Kopi Susu',
        availableProductStock: 10, // Plenty of product stock
        qtyToAdd: 1,
        addons: const [extraShot],
        addonStocks: const {1: 2}, // Addon stock is full (2 used out of 2)
      );

      expect(result.isValid, isFalse);
      expect(result.isAddon, isTrue);
      expect(result.failedId, extraShot.id);
      expect(result.remainingStock, 0);
      expect(result.message, contains('Extra Shot'));
      expect(result.message, contains('Tersisa 0'));
    });

    test('Perubahan qty ke atas ditolak saat melebihi stok, ke bawah diizinkan',
        () {
      final line = CartLine(
        productId: 10,
        productName: 'Kopi Susu',
        unitPrice: 18000,
        qty: 2,
        addons: const [extraShot],
      );
      final cart = [line];

      // Available product stock = 2
      // 1. Upward change: 2 -> 3 exceeds stock -> rejected
      final resultUp = validator.validateUpdateQty(
        currentCart: cart,
        targetLine: line,
        newQty: 3,
        availableProductStock: 2,
        addonStocks: const {1: 10},
      );
      expect(resultUp.isValid, isFalse);
      expect(resultUp.remainingStock, 0);
      expect(resultUp.message, contains('Tersisa 0'));

      // 2. Downward change: 2 -> 1 uses less stock -> allowed
      final resultDown = validator.validateUpdateQty(
        currentCart: cart,
        targetLine: line,
        newQty: 1,
        availableProductStock: 2,
        addonStocks: const {1: 10},
      );
      expect(resultDown.isValid, isTrue);
      expect(resultDown.remainingStock, 1);

      // 3. Same quantity: 2 -> 2 -> allowed
      final resultSame = validator.validateUpdateQty(
        currentCart: cart,
        targetLine: line,
        newQty: 2,
        availableProductStock: 2,
        addonStocks: const {1: 10},
      );
      expect(resultSame.isValid, isTrue);
      expect(resultSame.remainingStock, 0);

      // 4. Upward change rejected due to addon stock
      final resultAddonBlock = validator.validateUpdateQty(
        currentCart: cart,
        targetLine: line,
        newQty: 3,
        availableProductStock: 10,
        addonStocks: const {1: 2}, // Addon only has 2
      );
      expect(resultAddonBlock.isValid, isFalse);
      expect(resultAddonBlock.isAddon, isTrue);
      expect(resultAddonBlock.failedId, extraShot.id);
    });

    test('Produk stok 0 ditolak', () {
      final result = validator.validateAdd(
        currentCart: const [],
        productId: 20,
        productName: 'Matcha Latte',
        availableProductStock: 0,
        qtyToAdd: 1,
      );

      expect(result.isValid, isFalse);
      expect(result.remainingStock, 0);
      expect(result.message, contains('Matcha Latte'));
      expect(result.message, contains('habis'));
      expect(result.failedId, 20);
    });

    test('Add-on stok 0 ditolak saat ditambahkan', () {
      final result = validator.validateAdd(
        currentCart: const [],
        productId: 10,
        productName: 'Kopi Susu',
        availableProductStock: 10,
        qtyToAdd: 1,
        addons: const [caramelSyrup],
        addonStocks: const {2: 0},
      );

      expect(result.isValid, isFalse);
      expect(result.isAddon, isTrue);
      expect(result.failedId, caramelSyrup.id);
      expect(result.remainingStock, 0);
      expect(result.message, contains('Caramel Syrup'));
      expect(result.message, contains('habis'));
    });

    test('validateCart checks entire cart atomically', () {
      final cart = [
        CartLine(
          productId: 1,
          productName: 'Kopi Susu',
          unitPrice: 18000,
          qty: 2,
          addons: const [extraShot],
        ),
        CartLine(
          productId: 2,
          productName: 'Roti Bakar',
          unitPrice: 12000,
          qty: 1,
        ),
      ];

      // Both product and addon stocks are sufficient
      final validResult = validator.validateCart(
        cart: cart,
        productStocks: const {1: 5, 2: 3},
        addonStocks: const {1: 5},
      );
      expect(validResult.isValid, isTrue);

      // Product 1 stock insufficient (needs 2, has 1)
      final invalidProductResult = validator.validateCart(
        cart: cart,
        productStocks: const {1: 1, 2: 3},
        addonStocks: const {1: 5},
      );
      expect(invalidProductResult.isValid, isFalse);
      expect(invalidProductResult.failedId, 1);
      expect(invalidProductResult.remainingStock, 1);

      // Addon 1 stock insufficient (needs 2, has 1)
      final invalidAddonResult = validator.validateCart(
        cart: cart,
        productStocks: const {1: 5, 2: 3},
        addonStocks: const {1: 1},
      );
      expect(invalidAddonResult.isValid, isFalse);
      expect(invalidAddonResult.isAddon, isTrue);
      expect(invalidAddonResult.failedId, 1);
      expect(invalidAddonResult.remainingStock, 1);
    });
  });
}

