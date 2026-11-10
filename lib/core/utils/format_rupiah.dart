import 'package:intl/intl.dart';

final NumberFormat _rupiahFormat = NumberFormat.decimalPattern('id_ID');

/// Formats an integer amount into Rupiah representation (e.g. `Rp15.000`, `-Rp15.000`).
String formatRupiah(int amount) {
  if (amount < 0) {
    return '-Rp${_rupiahFormat.format(amount.abs())}';
  }
  return 'Rp${_rupiahFormat.format(amount)}';
}
