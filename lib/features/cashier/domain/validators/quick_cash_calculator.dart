/// Generates quick cash options for POS cashier payments.
///
/// Always provides the exact total ("Uang pas") as the first option,
/// followed by sensible Indonesian banknote denominations at or above the total.
class QuickCashCalculator {
  const QuickCashCalculator();

  List<int> calculateOptions(int total) {
    if (total <= 0) return const [0];

    final List<int> options = [total];

    if (total < 10000) {
      for (final amt in [10000, 20000, 50000]) {
        if (amt > total && !options.contains(amt)) {
          options.add(amt);
        }
      }
    } else {
      final candidates = <int>[
        ((total ~/ 10000) + 1) * 10000,
        ((total ~/ 20000) + 1) * 20000,
        ((total ~/ 50000) + 1) * 50000,
        ((total ~/ 100000) + 1) * 100000,
      ]..sort();

      for (final amt in candidates) {
        if (amt > total && !options.contains(amt)) {
          options.add(amt);
          if (options.length >= 4) break;
        }
      }
    }

    return options;
  }
}

