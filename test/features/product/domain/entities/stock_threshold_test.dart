import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/core/constants/app_constants.dart';
import 'package:vonte_pos/features/addon/domain/entities/addon.dart';
import 'package:vonte_pos/features/product/domain/entities/product.dart';

void main() {
  group('Product Stock Threshold Boundary Logic', () {
    const threshold = AppConstants.lowStockThreshold; // 5

    test('tepat di ambang (stock == 5): hasLowStock = true, isOutOfStock = false', () {
      const product = Product(
        id: 1,
        name: 'Kopi Susu',
        price: 15000,
        stock: threshold,
        createdAt: 1000,
        updatedAt: 1000,
      );

      expect(product.hasLowStock, isTrue);
      expect(product.isOutOfStock, isFalse);
    });

    test('di atas ambang (stock == 6): hasLowStock = false, isOutOfStock = false', () {
      const product = Product(
        id: 1,
        name: 'Kopi Susu',
        price: 15000,
        stock: threshold + 1,
        createdAt: 1000,
        updatedAt: 1000,
      );

      expect(product.hasLowStock, isFalse);
      expect(product.isOutOfStock, isFalse);
    });

    test('stok 0: hasLowStock = false, isOutOfStock = true', () {
      const product = Product(
        id: 1,
        name: 'Kopi Susu',
        price: 15000,
        stock: 0,
        createdAt: 1000,
        updatedAt: 1000,
      );

      expect(product.hasLowStock, isFalse);
      expect(product.isOutOfStock, isTrue);
    });

    test('stok negatif (-1): hasLowStock = false, isOutOfStock = true', () {
      const product = Product(
        id: 1,
        name: 'Kopi Susu',
        price: 15000,
        stock: -1,
        createdAt: 1000,
        updatedAt: 1000,
      );

      expect(product.hasLowStock, isFalse);
      expect(product.isOutOfStock, isTrue);
    });

    test('stok 1: hasLowStock = true, isOutOfStock = false', () {
      const product = Product(
        id: 1,
        name: 'Kopi Susu',
        price: 15000,
        stock: 1,
        createdAt: 1000,
        updatedAt: 1000,
      );

      expect(product.hasLowStock, isTrue);
      expect(product.isOutOfStock, isFalse);
    });
  });

  group('Addon Stock Threshold Boundary Logic', () {
    const threshold = AppConstants.lowStockThreshold; // 5

    test('tepat di ambang (stock == 5): isLowStock = true, isOutOfStock = false', () {
      const addon = Addon(
        id: 1,
        name: 'Extra Shot',
        price: 4000,
        stock: threshold,
      );

      expect(addon.isLowStock, isTrue);
      expect(addon.isOutOfStock, isFalse);
    });

    test('di atas ambang (stock == 6): isLowStock = false, isOutOfStock = false', () {
      const addon = Addon(
        id: 1,
        name: 'Extra Shot',
        price: 4000,
        stock: threshold + 1,
      );

      expect(addon.isLowStock, isFalse);
      expect(addon.isOutOfStock, isFalse);
    });

    test('stok 0: isLowStock = false, isOutOfStock = true', () {
      const addon = Addon(
        id: 1,
        name: 'Extra Shot',
        price: 4000,
        stock: 0,
      );

      expect(addon.isLowStock, isFalse);
      expect(addon.isOutOfStock, isTrue);
    });

    test('stok negatif (-1): isLowStock = false, isOutOfStock = true', () {
      const addon = Addon(
        id: 1,
        name: 'Extra Shot',
        price: 4000,
        stock: -1,
      );

      expect(addon.isLowStock, isFalse);
      expect(addon.isOutOfStock, isTrue);
    });

    test('deleted addon: isLowStock = false, isOutOfStock = false', () {
      const addon = Addon(
        id: 1,
        name: 'Extra Shot',
        price: 4000,
        stock: 2,
        isDeleted: true,
      );

      expect(addon.isLowStock, isFalse);
      expect(addon.isOutOfStock, isFalse);
    });
  });
}

