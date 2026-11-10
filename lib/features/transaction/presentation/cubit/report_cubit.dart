import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/get_report_use_case.dart';
import 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final GetReportUseCase getReportUseCase;
  final TransactionRepository? transactionRepository;
  StreamSubscription? _txSubscription;

  ReportCubit({
    required this.getReportUseCase,
    this.transactionRepository,
  }) : super(const ReportState()) {
    if (transactionRepository != null) {
      _txSubscription =
          transactionRepository!.onTransactionCommitted.listen((_) {
        loadReport();
      });
    }
  }

  @override
  Future<void> close() {
    _txSubscription?.cancel();
    return super.close();
  }

  Future<void> loadReport() async {
    emit(state.copyWith(
      status: ReportStatus.loading,
      clearError: true,
    ));

    try {
      final summary = await getReportUseCase();
      emit(state.copyWith(
        status: ReportStatus.success,
        summary: summary,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReportStatus.failure,
        errorMessage: AppStrings.loadReportFailed,
      ));
    }
  }
}

