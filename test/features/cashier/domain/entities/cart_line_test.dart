import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/features/addon/domain/entities/addon.dart';
import 'package:vonte_pos/features/cashier/domain/entities/cart_line.dart';

void main() {
  const extraShot = CartAddon(id: 1, name: 'Extra Shot', price: 3000);
  const oatMilk = CartAddon(id: 2, name: 'Oat Milk', price: 5000);

  group('CartAddon', () {
    test('creates CartAddon from Addon entity snapshot', () {
      const addon = Addon(
        id: 10,
        name: 'Gula Aren',
        price: 2000,
        stock: 50,
      );

      final cartAddon = CartAddon.fromAddon(addon);

      expect(cartAddon.id, 10);
      expect(cartAddon.name, 'Gula Aren');
      expect(cartAddon.price, 2000);
    });

    test('equality based on id, name, and price', () {
      const a1 = CartAddon(id: 1, name: 'Extra Shot', price: 3000);
      const a2 = CartAddon(id: 1, name: 'Extra Shot', price: 3000);
      const a3 = CartAddon(id: 1, name: 'Extra Shot 2', price: 3000);

      expect(a1, equals(a2));
      expect(a1, isNot(equals(a3)));
    });
  });

  group('CartLine identity', () {
    test('order of addons does not affect identity or equality', () {
      final line1 = CartLine(
        productId: 101,
        productName: 'Kopi Susu',
        unitPrice: 18000,
        qty: 1,
        addons: const [extraShot, oatMilk],
      );

      final line2 = CartLine(
        productId: 101,
        productName: 'Kopi Susu',
        unitPrice: 18000,
        qty: 1,
        addons: const [oatMilk, extraShot],
      );

      expect(line1.identityKey, equals(line2.identityKey));
      expect(line1.hasSameIdentity(line2), isTrue);
      expect(line1, equals(line2));
    });

    test('lines with different quantities still share the same identity', () {
      final line1 = CartLine(
        productId: 101,
        productName: 'Kopi Susu',
        unitPrice: 18000,
        qty: 1,
        addons: const [extraShot],
      );

      final line2 = CartLine(
        productId: 101,
        productName: 'Kopi Susu',
        unitPrice: 18000,
        qty: 3,
        addons: const [extraShot],
      );

      expect(line1.identityKey, equals(line2.identityKey));
      expect(line1.hasSameIdentity(line2), isTrue);
      expect(line1 == line2, isFalse);
    });

    test('different product IDs have different identities', () {
      final lineA = CartLine(
        productId: 101,
        productName: 'Kopi Susu',
        unitPrice: 18000,
        qty: 1,
      );

      final lineB = CartLine(
        productId: 102,
        productName: 'Americano',
        unitPrice: 15000,
        qty: 1,
      );

      expect(lineA.hasSameIdentity(lineB), isFalse);
      expect(lineA.identityKey, isNot(equals(lineB.identityKey)));
    });

    test('same product with different addons have different identities', () {
      final plain = CartLine(
        productId: 101,
        productName: 'Kopi Susu',
        unitPrice: 18000,
        qty: 1,
        addons: const [],
      );

      final withAddon = CartLine(
        productId: 101,
        productName: 'Kopi Susu',
        unitPrice: 18000,
        qty: 1,
        addons: const [extraShot],
      );

      expect(plain.hasSameIdentity(withAddon), isFalse);
      expect(plain.identityKey, isNot(equals(withAddon.identityKey)));
    });
  });

  group('CartLine price calculations', () {
    test('calculates line total without addons', () {
      final line = CartLine(
        productId: 1,
        productName: 'Roti Bakar',
        unitPrice: 12000,
        qty: 3,
      );

      expect(line.addonsUnitPrice, 0);
      expect(line.totalUnitPrice, 12000);
      expect(line.lineTotal, 36000);
    });

    test('calculates line total with attached addons', () {
      final line = CartLine(
        productId: 1,
        productName: 'Kopi Susu',
        unitPrice: 18000,
        qty: 2,
        addons: const [extraShot, oatMilk], // 3000 + 5000 = 8000
      );

      expect(line.addonsUnitPrice, 8000);
      expect(line.totalUnitPrice, 26000);
      expect(line.lineTotal, 52000);
    });

    test('copyWith creates a new instance with updated fields', () {
      final line = CartLine(
        productId: 1,
        productName: 'Kopi Susu',
        unitPrice: 18000,
        qty: 1,
      );

      final updated = line.copyWith(qty: 4);

      expect(updated.qty, 4);
      expect(updated.productId, 1);
      expect(updated.lineTotal, 72000);
    });
  });
}

