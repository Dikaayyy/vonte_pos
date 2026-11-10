import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/features/cashier/domain/entities/cart_line.dart';
import 'package:vonte_pos/features/cashier/domain/entities/cart_totals.dart';
import 'package:vonte_pos/features/cashier/domain/entities/discount.dart';

void main() {
  group('CartTotals', () {
    const extraShot = CartAddon(id: 1, name: 'Extra Shot', price: 3000);

    test('computes totals accurately from cart lines without discount', () {
      final lines = [
        CartLine(
          productId: 1,
          productName: 'Kopi Susu',
          unitPrice: 18000,
          qty: 2,
          addons: const [extraShot], // 21000 * 2 = 42000
        ),
        CartLine(
          productId: 2,
          productName: 'Roti Bakar',
          unitPrice: 15000,
          qty: 1, // 15000
        ),
      ];

      final totals = CartTotals.compute(lines: lines);

      expect(totals.subtotal, 57000);
      expect(totals.discountAmount, 0);
      expect(totals.discount, 0);
      expect(totals.total, 57000);
    });

    test('computes totals accurately with percentage discount and half-up rounding', () {
      final lines = [
        CartLine(
          productId: 1,
          productName: 'Kopi Susu',
          unitPrice: 10005,
          qty: 1,
        ),
      ];

      // 10005 with 15% discount -> discountAmount = 1501, total = 8504
      final totals = CartTotals.compute(
        lines: lines,
        discount: const Discount.percent(15),
      );

      expect(totals.subtotal, 10005);
      expect(totals.discountAmount, 1501);
      expect(totals.total, 8504);
    });

    test('computes totals with fixed discount', () {
      final totals = CartTotals.fromSubtotal(
        subtotal: 50000,
        discount: const Discount.fixed(10000),
      );

      expect(totals.subtotal, 50000);
      expect(totals.discountAmount, 10000);
      expect(totals.total, 40000);
    });

    test('empty lines produce zero totals', () {
      final totals = CartTotals.compute(lines: const []);

      expect(totals.subtotal, 0);
      expect(totals.discountAmount, 0);
      expect(totals.total, 0);
    });
  });
}

