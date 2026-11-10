import '../../../../core/utils/clock.dart';

/// Pure domain service to generate formatted daily invoice numbers.
/// Format: `VNT-YYYYMMDD-0001`
class InvoiceNumberGenerator {
  final Clock clock;

  const InvoiceNumberGenerator({this.clock = const SystemClock()});

  /// Formats date to YYYYMMDD string.
  static String formatDate(DateTime dateTime) {
    final y = dateTime.year.toString().padLeft(4, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }

  /// Builds the expected invoice prefix for a given [date].
  String prefixForDate(DateTime date) {
    return 'VNT-${formatDate(date)}-';
  }

  /// Generates the next invoice number based on [lastInvoiceNo].
  /// Resets sequence to 0001 if date changes or [lastInvoiceNo] is null or from a different day.
  String generate({String? lastInvoiceNo, DateTime? forTime}) {
    final time = forTime ?? clock.now();
    final prefix = prefixForDate(time);

    if (lastInvoiceNo == null || !lastInvoiceNo.startsWith(prefix)) {
      return '${prefix}0001';
    }

    final seqStr = lastInvoiceNo.substring(prefix.length);
    final currentSeq = int.tryParse(seqStr) ?? 0;
    final nextSeq = currentSeq + 1;
    return '$prefix${nextSeq.toString().padLeft(4, '0')}';
  }
}

