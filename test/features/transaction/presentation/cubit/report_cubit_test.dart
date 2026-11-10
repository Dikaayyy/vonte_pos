import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/features/transaction/domain/entities/report_summary.dart';
import 'package:vonte_pos/features/transaction/domain/entities/transaction.dart';
import 'package:vonte_pos/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:vonte_pos/features/transaction/domain/usecases/get_report_use_case.dart';
import 'package:vonte_pos/features/transaction/presentation/cubit/report_cubit.dart';
import 'package:vonte_pos/features/transaction/presentation/cubit/report_state.dart';

class MockGetReportUseCase extends Mock implements GetReportUseCase {}
class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockGetReportUseCase mockGetReportUseCase;

  setUp(() {
    mockGetReportUseCase = MockGetReportUseCase();
  });

  group('ReportCubit Tests', () {
    const testTransaction = Transaction(
      id: 1,
      invoiceNo: 'VNT-20261110-0001',
      cashierId: 1,
      cashierName: 'Budi',
      storeName: 'Vonte Coffee',
      storeAddress: 'Jl. Merdeka No. 1',
      storePhone: '081234567890',
      subtotal: 30000,
      discountType: 'none',
      discountValue: 0,
      discountAmount: 0,
      total: 30000,
      cashReceived: 50000,
      changeAmount: 20000,
      createdAt: 1000,
      items: [],
    );

    const testSummary = ReportSummary(
      totalRevenue: 30000,
      transactionCount: 1,
      transactions: [testTransaction],
    );

    test('initial state has ReportStatus.initial and empty summary', () {
      final cubit = ReportCubit(getReportUseCase: mockGetReportUseCase);
      expect(cubit.state.status, ReportStatus.initial);
      expect(cubit.state.summary, ReportSummary.empty);
      expect(cubit.state.totalRevenue, 0);
      expect(cubit.state.transactionCount, 0);
      expect(cubit.state.transactions, isEmpty);
      expect(cubit.state.errorMessage, isNull);
    });

    blocTest<ReportCubit, ReportState>(
      'emits [loading, success] when loadReport succeeds',
      build: () {
        when(() => mockGetReportUseCase()).thenAnswer((_) async => testSummary);
        return ReportCubit(getReportUseCase: mockGetReportUseCase);
      },
      act: (cubit) => cubit.loadReport(),
      expect: () => [
        const ReportState(
          status: ReportStatus.loading,
          summary: ReportSummary.empty,
        ),
        const ReportState(
          status: ReportStatus.success,
          summary: testSummary,
        ),
      ],
      verify: (_) {
        verify(() => mockGetReportUseCase()).called(1);
      },
    );

    blocTest<ReportCubit, ReportState>(
      'emits [loading, failure] when loadReport throws an error',
      build: () {
        when(() => mockGetReportUseCase())
            .thenThrow(Exception('Database error'));
        return ReportCubit(getReportUseCase: mockGetReportUseCase);
      },
      act: (cubit) => cubit.loadReport(),
      expect: () => [
        const ReportState(
          status: ReportStatus.loading,
          summary: ReportSummary.empty,
        ),
        const ReportState(
          status: ReportStatus.failure,
          summary: ReportSummary.empty,
          errorMessage: AppStrings.loadReportFailed,
        ),
      ],
      verify: (_) {
        verify(() => mockGetReportUseCase()).called(1);
      },
    );

    test('reloads report in real-time when transactionRepository commits a transaction',
        () async {
      final mockRepo = MockTransactionRepository();
      final streamController = StreamController<Transaction>.broadcast();
      when(() => mockRepo.onTransactionCommitted)
          .thenAnswer((_) => streamController.stream);
      when(() => mockGetReportUseCase()).thenAnswer((_) async => testSummary);

      final cubit = ReportCubit(
        getReportUseCase: mockGetReportUseCase,
        transactionRepository: mockRepo,
      );

      // Trigger transaction committed
      streamController.add(testTransaction);
      await pumpEventQueue();

      expect(cubit.state.status, equals(ReportStatus.success));
      expect(cubit.state.summary, equals(testSummary));
      verify(() => mockGetReportUseCase()).called(1);

      await cubit.close();
      await streamController.close();
    });
  });
}

