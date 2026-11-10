import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/features/cashier/domain/validators/cash_calculator.dart';

void main() {
  const calculator = CashCalculator();

  group('CashCalculator', () {
    const total = 45000;

    test('Uang kurang ditolak dan mengembalikan selisih kekurangan', () {
      const cashReceived = 40000;

      final result = calculator.validatePayment(
        cashReceived: cashReceived,
        total: total,
      );

      expect(result.isValid, isFalse);
      expect(result.shortage, 5000);
      expect(result.change, 0);
      expect(result.message, isNotNull);

      // calculateChange should throw ArgumentError when cash received < total
      expect(
        () => calculator.calculateChange(
          cashReceived: cashReceived,
          total: total,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Uang pas diterima dengan kembalian 0', () {
      const cashReceived = 45000;

      final result = calculator.validatePayment(
        cashReceived: cashReceived,
        total: total,
      );

      expect(result.isValid, isTrue);
      expect(result.change, 0);
      expect(result.shortage, 0);
      expect(result.message, isNull);

      final change = calculator.calculateChange(
        cashReceived: cashReceived,
        total: total,
      );
      expect(change, 0);
    });

    test('Kembalian dihitung dengan tepat saat uang diterima lebih besar dari total', () {
      const cashReceived = 100000;

      final result = calculator.validatePayment(
        cashReceived: cashReceived,
        total: total,
      );

      expect(result.isValid, isTrue);
      expect(result.change, 55000);
      expect(result.shortage, 0);

      final change = calculator.calculateChange(
        cashReceived: cashReceived,
        total: total,
      );
      expect(change, 55000);
    });

    test('Nominal pembayaran negatif ditolak', () {
      final resultCashNegative = calculator.validatePayment(
        cashReceived: -1000,
        total: total,
      );
      expect(resultCashNegative.isValid, isFalse);

      final resultTotalNegative = calculator.validatePayment(
        cashReceived: 50000,
        total: -100,
      );
      expect(resultTotalNegative.isValid, isFalse);
    });
  });
}

