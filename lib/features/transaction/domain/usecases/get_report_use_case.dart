import '../entities/report_summary.dart';
import '../repositories/transaction_repository.dart';

/// Retrieves transaction snapshots and aggregates report metrics (total revenue, transaction count, history).
class GetReportUseCase {
  final TransactionRepository _repository;

  const GetReportUseCase(this._repository);

  Future<ReportSummary> call() async {
    final transactions = await _repository.getTransactions();
    return ReportSummary.fromTransactions(transactions);
  }
}

