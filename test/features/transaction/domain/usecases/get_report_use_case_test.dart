import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vonte_pos/features/transaction/domain/entities/report_summary.dart';
import 'package:vonte_pos/features/transaction/domain/entities/transaction.dart';
import 'package:vonte_pos/features/transaction/domain/entities/transaction_item.dart';
import 'package:vonte_pos/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:vonte_pos/features/transaction/domain/usecases/get_report_use_case.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockTransactionRepository mockRepository;
  late GetReportUseCase useCase;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = GetReportUseCase(mockRepository);
  });

  group('GetReportUseCase & ReportSummary Domain Tests', () {
    test('returns empty summary when there are no transactions', () async {
      when(() => mockRepository.getTransactions()).thenAnswer((_) async => []);

      final result = await useCase();

      expect(result.totalRevenue, 0);
      expect(result.transactionCount, 0);
      expect(result.transactions, isEmpty);
      expect(result, equals(ReportSummary.empty));
      verify(() => mockRepository.getTransactions()).called(1);
    });

    test('calculates correct total revenue and count from multiple transactions',
        () async {
      final tx1 = const Transaction(
        id: 1,
        invoiceNo: 'VNT-20261110-0001',
        cashierId: 1,
        cashierName: 'Budi',
        storeName: 'Vonte Coffee',
        storeAddress: 'Jl. Merdeka No. 1',
        storePhone: '081234567890',
        subtotal: 50000,
        discountType: 'none',
        discountValue: 0,
        discountAmount: 0,
        total: 50000,
        cashReceived: 50000,
        changeAmount: 0,
        createdAt: 1000,
        items: [
          TransactionItem(
            productId: 1,
            productName: 'Kopi Susu',
            unitPrice: 25000,
            qty: 2,
            lineTotal: 50000,
          ),
        ],
      );

      final tx2 = const Transaction(
        id: 2,
        invoiceNo: 'VNT-20261110-0002',
        cashierId: 1,
        cashierName: 'Budi',
        storeName: 'Vonte Coffee',
        storeAddress: 'Jl. Merdeka No. 1',
        storePhone: '081234567890',
        subtotal: 75000,
        discountType: 'fixed',
        discountValue: 5000,
        discountAmount: 5000,
        total: 70000,
        cashReceived: 100000,
        changeAmount: 30000,
        createdAt: 2000,
        items: [
          TransactionItem(
            productId: 2,
            productName: 'Croissant',
            unitPrice: 35000,
            qty: 2,
            lineTotal: 70000,
          ),
        ],
      );

      when(() => mockRepository.getTransactions())
          .thenAnswer((_) async => [tx2, tx1]);

      final result = await useCase();

      expect(result.totalRevenue, 120000); // 50000 + 70000
      expect(result.transactionCount, 2);
      expect(result.transactions.length, 2);
      expect(result.transactions.first.invoiceNo, 'VNT-20261110-0002');
      expect(result.transactions.last.invoiceNo, 'VNT-20261110-0001');
      verify(() => mockRepository.getTransactions()).called(1);
    });
  });
}

