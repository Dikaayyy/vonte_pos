import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/core/utils/format_rupiah.dart';

void main() {
  group('formatRupiah', () {
    test('formats 0 as Rp0', () {
      expect(formatRupiah(0), 'Rp0');
    });

    test('formats positive amounts without spaces', () {
      expect(formatRupiah(15000), 'Rp15.000');
      expect(formatRupiah(1500000), 'Rp1.500.000');
    });

    test('formats negative amounts with minus before prefix', () {
      expect(formatRupiah(-15000), '-Rp15.000');
    });
  });
}

