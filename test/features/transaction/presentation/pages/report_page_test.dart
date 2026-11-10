import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/features/transaction/domain/entities/report_summary.dart';
import 'package:vonte_pos/features/transaction/domain/entities/transaction.dart';
import 'package:vonte_pos/features/transaction/domain/entities/transaction_item.dart';
import 'package:vonte_pos/features/transaction/domain/usecases/get_report_use_case.dart';
import 'package:vonte_pos/features/transaction/presentation/cubit/report_cubit.dart';
import 'package:vonte_pos/features/transaction/presentation/pages/receipt_page.dart';
import 'package:vonte_pos/features/transaction/presentation/pages/report_page.dart';

class MockGetReportUseCase extends Mock implements GetReportUseCase {}

void main() {
  late MockGetReportUseCase mockGetReportUseCase;
  late ReportCubit reportCubit;

  setUp(() {
    mockGetReportUseCase = MockGetReportUseCase();
    when(() => mockGetReportUseCase()).thenAnswer(
      (_) async => ReportSummary.empty,
    );
    reportCubit = ReportCubit(getReportUseCase: mockGetReportUseCase);
  });

  tearDown(() {
    reportCubit.close();
  });

  Widget buildTestWidget({ReportCubit? cubit}) {
    return MaterialApp(
      home: BlocProvider<ReportCubit>.value(
        value: cubit ?? reportCubit,
        child: const ReportPage(),
      ),
    );
  }

  group('ReportPage Widget Tests', () {
    testWidgets('renders header, stat cards with 0, and EmptyState when no transactions',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Header
      expect(find.text(AppStrings.reportTitle), findsOneWidget);
      expect(find.text(AppStrings.reportSubtitle), findsOneWidget);

      // Stat cards
      expect(find.text(AppStrings.totalRevenueLabel), findsOneWidget);
      expect(find.text('Rp0'), findsOneWidget);
      expect(find.text(AppStrings.successfulTransactionsLabel), findsOneWidget);
      expect(find.text('0'), findsOneWidget);

      // Empty State
      expect(find.text(AppStrings.emptyTransactionsTitle), findsOneWidget);
      expect(find.text(AppStrings.emptyTransactionsSubtitle), findsOneWidget);
    });

    testWidgets('renders stat cards and transaction list when data is available',
        (tester) async {
      const sampleTx = Transaction(
        id: 1,
        invoiceNo: 'VNT-20261110-0001',
        cashierId: 1,
        cashierName: 'Budi Hartono',
        storeName: 'Vonte Coffee',
        storeAddress: 'Jl. Merdeka No. 1',
        storePhone: '081234567890',
        subtotal: 35000,
        discountType: 'none',
        discountValue: 0,
        discountAmount: 0,
        total: 35000,
        cashReceived: 50000,
        changeAmount: 15000,
        createdAt: 1762759800000,
        items: [
          TransactionItem(
            productId: 1,
            productName: 'Caramel Macchiato',
            unitPrice: 35000,
            qty: 1,
            lineTotal: 35000,
          ),
        ],
      );

      final summary = const ReportSummary(
        totalRevenue: 35000,
        transactionCount: 1,
        transactions: [sampleTx],
      );

      when(() => mockGetReportUseCase()).thenAnswer((_) async => summary);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Stat cards
      expect(find.text('Rp35.000'), findsWidgets); // Stat card & price
      expect(find.text('1'), findsOneWidget); // Count in stat card

      // History section header & badge
      expect(find.text(AppStrings.transactionHistoryTitle), findsOneWidget);
      expect(find.text('1 ${AppStrings.transactionCountUnit}'), findsOneWidget);

      // Transaction row card
      expect(find.text('VNT-20261110-0001'), findsOneWidget);
      expect(find.text('• 1 item'), findsOneWidget);
    });

    testWidgets('tapping a transaction card opens ReceiptPage', (tester) async {
      const sampleTx = Transaction(
        id: 1,
        invoiceNo: 'VNT-20261110-0001',
        cashierId: 1,
        cashierName: 'Budi Hartono',
        storeName: 'Vonte Coffee',
        storeAddress: 'Jl. Merdeka No. 1',
        storePhone: '081234567890',
        subtotal: 35000,
        discountType: 'none',
        discountValue: 0,
        discountAmount: 0,
        total: 35000,
        cashReceived: 50000,
        changeAmount: 15000,
        createdAt: 1762759800000,
        items: [
          TransactionItem(
            productId: 1,
            productName: 'Caramel Macchiato',
            unitPrice: 35000,
            qty: 1,
            lineTotal: 35000,
          ),
        ],
      );

      final summary = const ReportSummary(
        totalRevenue: 35000,
        transactionCount: 1,
        transactions: [sampleTx],
      );

      when(() => mockGetReportUseCase()).thenAnswer((_) async => summary);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap transaction card
      await tester.tap(find.text('VNT-20261110-0001'));
      await tester.pumpAndSettle();

      // Verifies ReceiptPage opened
      expect(find.byType(ReceiptPage), findsOneWidget);
      expect(find.text(AppStrings.receiptTitle), findsOneWidget);
      expect(find.text('Caramel Macchiato'), findsOneWidget);
    });

    testWidgets('shows error state and retry button on failure', (tester) async {
      when(() => mockGetReportUseCase())
          .thenThrow(Exception('Database error'));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.loadReportFailed), findsOneWidget);
      expect(find.text(AppStrings.retry), findsOneWidget);

      // Tapping retry triggers loadReport again
      reset(mockGetReportUseCase);
      when(() => mockGetReportUseCase()).thenAnswer(
        (_) async => ReportSummary.empty,
      );

      await tester.tap(find.text(AppStrings.retry));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.emptyTransactionsTitle), findsOneWidget);
    });

    testWidgets('tapping refresh button in header reloads report', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Initial call in initState
      verify(() => mockGetReportUseCase()).called(1);

      // Tap refresh icon
      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pumpAndSettle();

      verify(() => mockGetReportUseCase()).called(1);
    });
  });
}
