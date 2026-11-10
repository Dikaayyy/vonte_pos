import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/core/utils/clock.dart';
import 'package:vonte_pos/features/transaction/domain/services/invoice_number_generator.dart';

void main() {
  group('InvoiceNumberGenerator Unit Tests', () {
    late TestClock testClock;
    late InvoiceNumberGenerator generator;

    setUp(() {
      testClock = TestClock(DateTime(2026, 11, 10, 10, 0, 0));
      generator = InvoiceNumberGenerator(clock: testClock);
    });

    test('generates VNT-YYYYMMDD-0001 when lastInvoiceNo is null', () {
      final invoice = generator.generate();
      expect(invoice, 'VNT-20261110-0001');
    });

    test('increments sequence when lastInvoiceNo is from same day', () {
      final invoice2 = generator.generate(lastInvoiceNo: 'VNT-20261110-0001');
      expect(invoice2, 'VNT-20261110-0002');

      final invoice99 = generator.generate(lastInvoiceNo: 'VNT-20261110-0099');
      expect(invoice99, 'VNT-20261110-0100');
    });

    test('resets sequence to 0001 when date advances to next day', () {
      final todayInvoice = generator.generate(lastInvoiceNo: 'VNT-20261110-0042');
      expect(todayInvoice, 'VNT-20261110-0043');

      // Advance clock to next day
      testClock.setTime(DateTime(2026, 11, 11, 8, 30, 0));

      // With previous day invoice passed, it resets to 0001
      final tomorrowInvoice = generator.generate(lastInvoiceNo: 'VNT-20261110-0043');
      expect(tomorrowInvoice, 'VNT-20261111-0001');
    });

    test('resets to 0001 when lastInvoiceNo does not match prefix', () {
      final invoice = generator.generate(lastInvoiceNo: 'INVALID-PREFIX-1234');
      expect(invoice, 'VNT-20261110-0001');
    });
  });
}

