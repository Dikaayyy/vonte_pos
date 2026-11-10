import 'package:equatable/equatable.dart';

import 'transaction.dart';

/// Aggregated report summary containing total revenue, successful transaction count,
/// and the list of transaction snapshots.
class ReportSummary extends Equatable {
  final int totalRevenue;
  final int transactionCount;
  final List<Transaction> transactions;

  const ReportSummary({
    required this.totalRevenue,
    required this.transactionCount,
    required this.transactions,
  });

  /// Factory calculating summary totals from a list of transactions.
  factory ReportSummary.fromTransactions(List<Transaction> transactions) {
    final revenue = transactions.fold<int>(0, (sum, tx) => sum + tx.total);
    return ReportSummary(
      totalRevenue: revenue,
      transactionCount: transactions.length,
      transactions: transactions,
    );
  }

  /// Empty summary for initial / no transaction state.
  static const empty = ReportSummary(
    totalRevenue: 0,
    transactionCount: 0,
    transactions: [],
  );

  @override
  List<Object?> get props => [totalRevenue, transactionCount, transactions];
}

