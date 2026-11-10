import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vonte_pos/core/error/failures.dart';
import 'package:vonte_pos/core/error/result.dart';
import 'package:vonte_pos/features/cashier/domain/entities/cart_line.dart';
import 'package:vonte_pos/features/cashier/domain/entities/discount.dart';
import 'package:vonte_pos/features/transaction/domain/entities/checkout_params.dart';
import 'package:vonte_pos/features/transaction/domain/entities/transaction.dart';
import 'package:vonte_pos/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:vonte_pos/features/transaction/domain/usecases/checkout_use_case.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const CheckoutParams(
        lines: [],
        cashReceived: 0,
        cashierId: 1,
        cashierName: 'Kasir',
      ),
    );
  });

  group('CheckoutUseCase Unit Tests', () {
    late MockTransactionRepository mockRepository;
    late CheckoutUseCase useCase;

    setUp(() {
      mockRepository = MockTransactionRepository();
      useCase = CheckoutUseCase(mockRepository);
    });

    test('returns failure when cart lines are empty', () async {
      const params = CheckoutParams(
        lines: [],
        cashReceived: 50000,
        cashierId: 1,
        cashierName: 'Budi',
      );

      final result = await useCase(params);

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(result.failureOrNull?.message, 'Keranjang belanja kosong.');
      verifyZeroInteractions(mockRepository);
    });

    test('returns failure when discount percent exceeds 100', () async {
      final lines = [
        CartLine(
          productId: 1,
          productName: 'Kopi',
          unitPrice: 20000,
          qty: 1,
        ),
      ];
      final params = CheckoutParams(
        lines: lines,
        discount: const Discount.percent(150),
        cashReceived: 50000,
        cashierId: 1,
        cashierName: 'Budi',
      );

      final result = await useCase(params);

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
      verifyZeroInteractions(mockRepository);
    });

    test('returns failure when fixed discount exceeds subtotal', () async {
      final lines = [
        CartLine(
          productId: 1,
          productName: 'Kopi',
          unitPrice: 20000,
          qty: 1,
        ),
      ];
      final params = CheckoutParams(
        lines: lines,
        discount: const Discount.fixed(25000),
        cashReceived: 50000,
        cashierId: 1,
        cashierName: 'Budi',
      );

      final result = await useCase(params);

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
      verifyZeroInteractions(mockRepository);
    });

    test('returns failure when cash payment is less than total', () async {
      final lines = [
        CartLine(
          productId: 1,
          productName: 'Kopi',
          unitPrice: 20000,
          qty: 1,
        ),
      ];
      final params = CheckoutParams(
        lines: lines,
        discount: const Discount.none(),
        cashReceived: 10000, // total is 20000, short by 10000
        cashierId: 1,
        cashierName: 'Budi',
      );

      final result = await useCase(params);

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
      verifyZeroInteractions(mockRepository);
    });

    test('delegates to repository when domain validation passes', () async {
      final lines = [
        CartLine(
          productId: 1,
          productName: 'Kopi',
          unitPrice: 20000,
          qty: 1,
        ),
      ];
      final params = CheckoutParams(
        lines: lines,
        discount: const Discount.percent(10),
        cashReceived: 20000,
        cashierId: 1,
        cashierName: 'Budi',
      );

      const expectedTx = Transaction(
        id: 1,
        invoiceNo: 'VNT-20261110-0001',
        cashierId: 1,
        cashierName: 'Budi',
        storeName: 'Vonte PoS',
        storeAddress: 'Jl. Test',
        storePhone: '08123456789',
        subtotal: 20000,
        discountType: 'percent',
        discountValue: 10,
        discountAmount: 2000,
        total: 18000,
        cashReceived: 20000,
        changeAmount: 2000,
        createdAt: 1000,
      );

      when(() => mockRepository.checkout(any()))
          .thenAnswer((_) async => const Result.success(expectedTx));

      final result = await useCase(params);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, equals(expectedTx));
      verify(() => mockRepository.checkout(params)).called(1);
    });
  });
}

