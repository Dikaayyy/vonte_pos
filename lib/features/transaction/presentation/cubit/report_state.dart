import 'package:equatable/equatable.dart';

import '../../domain/entities/report_summary.dart';
import '../../domain/entities/transaction.dart';

enum ReportStatus { initial, loading, success, failure }

class ReportState extends Equatable {
  final ReportStatus status;
  final ReportSummary summary;
  final String? errorMessage;

  const ReportState({
    this.status = ReportStatus.initial,
    this.summary = ReportSummary.empty,
    this.errorMessage,
  });

  int get totalRevenue => summary.totalRevenue;
  int get transactionCount => summary.transactionCount;
  List<Transaction> get transactions => summary.transactions;

  ReportState copyWith({
    ReportStatus? status,
    ReportSummary? summary,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReportState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, summary, errorMessage];
}

