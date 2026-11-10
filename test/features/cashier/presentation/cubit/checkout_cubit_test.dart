import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/core/error/failures.dart';
import 'package:vonte_pos/core/error/result.dart';
import 'package:vonte_pos/features/cashier/domain/entities/cart_line.dart';
import 'package:vonte_pos/features/cashier/domain/entities/discount.dart';
import 'package:vonte_pos/features/cashier/presentation/cubit/checkout_cubit.dart';
import 'package:vonte_pos/features/cashier/presentation/cubit/checkout_state.dart';
import 'package:vonte_pos/features/transaction/domain/entities/checkout_params.dart';
import 'package:vonte_pos/features/transaction/domain/entities/transaction.dart';
import 'package:vonte_pos/features/transaction/domain/usecases/checkout_use_case.dart';

class MockCheckoutUseCase extends Mock implements CheckoutUseCase {}

void main() {
  late MockCheckoutUseCase mockCheckoutUseCase;
  late CheckoutCubit checkoutCubit;

  final List<CartLine> sampleLines = [
    CartLine(
      productId: 1,
      productName: 'Kopi Susu',
      unitPrice: 25000,
      qty: 2,
    ),
  ]; // subtotal = 50.000

  const sampleTransaction = Transaction(
    id: 1,
    invoiceNo: 'VNT-20261110-0001',
    cashierId: 1,
    cashierName: 'Budi Kasir',
    storeName: 'Vonte Coffee',
    storeAddress: 'Jl. Sudirman No. 10',
    storePhone: '081234567890',
    subtotal: 50000,
    discountType: 'none',
    discountValue: 0,
    discountAmount: 0,
    total: 50000,
    cashReceived: 50000,
    changeAmount: 0,
    createdAt: 1700000000000,
  );

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

  setUp(() {
    mockCheckoutUseCase = MockCheckoutUseCase();
    checkoutCubit = CheckoutCubit(checkoutUseCase: mockCheckoutUseCase);
  });

  tearDown(() {
    checkoutCubit.close();
  });

  group('CheckoutCubit - init & quick cash', () {
    test('initial state has empty defaults', () {
      expect(checkoutCubit.state.status, equals(CheckoutStatus.initial));
      expect(checkoutCubit.state.subtotal, equals(0));
      expect(checkoutCubit.state.total, equals(0));
      expect(checkoutCubit.state.isValid, isFalse);
    });

    blocTest<CheckoutCubit, CheckoutState>(
      'init correctly computes subtotal, total, and quick cash options',
      build: () => checkoutCubit,
      act: (cubit) => cubit.init(
        lines: sampleLines,
        cashierId: 1,
        cashierName: 'Budi Kasir',
        storeName: 'Vonte Coffee',
      ),
      expect: () => [
        isA<CheckoutState>()
            .having((s) => s.subtotal, 'subtotal', 50000)
            .having((s) => s.total, 'total', 50000)
            .having((s) => s.cashierName, 'cashierName', 'Budi Kasir')
            .having((s) => s.quickCashOptions, 'quickCashOptions', contains(50000))
            .having((s) => s.cashError, 'cashError', AppStrings.paymentShortage)
            .having((s) => s.isValid, 'isValid', isFalse),
      ],
    );
  });

  group('CheckoutCubit - Diskon (Rule 4: Discount Protection)', () {
    setUp(() {
      checkoutCubit.init(
        lines: sampleLines,
        cashierId: 1,
        cashierName: 'Budi Kasir',
      );
    });

    blocTest<CheckoutCubit, CheckoutState>(
      'valid percent discount (10%) applies correctly',
      build: () => checkoutCubit,
      act: (cubit) {
        cubit.setDiscountType(DiscountType.percent);
        cubit.setDiscountInput('10');
      },
      skip: 1,
      expect: () => [
        isA<CheckoutState>()
            .having((s) => s.discountType, 'type', DiscountType.percent)
            .having((s) => s.discountValue, 'value', 10)
            .having((s) => s.discountAmount, 'amount', 5000)
            .having((s) => s.total, 'total', 45000)
            .having((s) => s.discountError, 'discountError', isNull),
      ],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'percent discount > 100 shows inline error and blocks payment',
      build: () => checkoutCubit,
      act: (cubit) {
        cubit.setDiscountType(DiscountType.percent);
        cubit.setDiscountInput('105');
      },
      skip: 1,
      expect: () => [
        isA<CheckoutState>()
            .having((s) => s.discountError, 'discountError', AppStrings.discountPercentOutOfRange)
            .having((s) => s.isValid, 'isValid', isFalse),
      ],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'percent discount < 0 shows inline error and blocks payment',
      build: () => checkoutCubit,
      act: (cubit) {
        cubit.setDiscountType(DiscountType.percent);
        cubit.setDiscountInput('-5');
      },
      skip: 1,
      expect: () => [
        isA<CheckoutState>()
            .having((s) => s.discountError, 'discountError', AppStrings.discountPercentOutOfRange)
            .having((s) => s.isValid, 'isValid', isFalse),
      ],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'valid fixed discount (Rp10.000) applies correctly',
      build: () => checkoutCubit,
      act: (cubit) {
        cubit.setDiscountType(DiscountType.fixed);
        cubit.setDiscountInput('10000');
      },
      expect: () => [
        isA<CheckoutState>()
            .having((s) => s.discountType, 'type', DiscountType.fixed)
            .having((s) => s.discountValue, 'value', 10000)
            .having((s) => s.discountAmount, 'amount', 10000)
            .having((s) => s.total, 'total', 40000)
            .having((s) => s.discountError, 'discountError', isNull),
      ],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'fixed discount > subtotal shows inline error and blocks payment',
      build: () => checkoutCubit,
      act: (cubit) {
        cubit.setDiscountType(DiscountType.fixed);
        cubit.setDiscountInput('55000'); // subtotal is 50.000
      },
      expect: () => [
        isA<CheckoutState>()
            .having((s) => s.discountError, 'discountError', AppStrings.discountFixedExceedsSubtotal)
            .having((s) => s.isValid, 'isValid', isFalse),
      ],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'fixed discount < 0 shows inline error and blocks payment',
      build: () => checkoutCubit,
      act: (cubit) {
        cubit.setDiscountType(DiscountType.fixed);
        cubit.setDiscountInput('-1000');
      },
      expect: () => [
        isA<CheckoutState>()
            .having((s) => s.discountError, 'discountError', AppStrings.discountFixedNegative)
            .having((s) => s.isValid, 'isValid', isFalse),
      ],
    );
  });

  group('CheckoutCubit - Cash received & live change', () {
    setUp(() {
      checkoutCubit.init(
        lines: sampleLines,
        cashierId: 1,
        cashierName: 'Budi Kasir',
      );
    });

    blocTest<CheckoutCubit, CheckoutState>(
      'cash received less than total shows shortage and disables payment',
      build: () => checkoutCubit,
      act: (cubit) => cubit.setCashReceivedInput('30000'), // total is 50.000
      expect: () => [
        isA<CheckoutState>()
            .having((s) => s.cashReceived, 'cashReceived', 30000)
            .having((s) => s.changeAmount, 'changeAmount', 0)
            .having((s) => s.cashError, 'cashError', AppStrings.paymentShortage)
            .having((s) => s.isValid, 'isValid', isFalse),
      ],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'cash received exactly total ("Uang pas") is valid with 0 change',
      build: () => checkoutCubit,
      act: (cubit) => cubit.selectQuickCash(50000),
      expect: () => [
        isA<CheckoutState>()
            .having((s) => s.cashReceived, 'cashReceived', 50000)
            .having((s) => s.changeAmount, 'changeAmount', 0)
            .having((s) => s.cashError, 'cashError', isNull)
            .having((s) => s.isValid, 'isValid', isTrue),
      ],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'cash received greater than total computes live change and enables payment',
      build: () => checkoutCubit,
      act: (cubit) => cubit.setCashReceivedInput('100000'),
      expect: () => [
        isA<CheckoutState>()
            .having((s) => s.cashReceived, 'cashReceived', 100000)
            .having((s) => s.changeAmount, 'changeAmount', 50000)
            .having((s) => s.cashError, 'cashError', isNull)
            .having((s) => s.isValid, 'isValid', isTrue),
      ],
    );
  });

  group('CheckoutCubit - submitPayment execution', () {
    setUp(() {
      checkoutCubit.init(
        lines: sampleLines,
        cashierId: 1,
        cashierName: 'Budi Kasir',
      );
    });

    blocTest<CheckoutCubit, CheckoutState>(
      'does nothing when state is invalid (cash not entered)',
      build: () => checkoutCubit,
      act: (cubit) => cubit.submitPayment(),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockCheckoutUseCase.call(any()));
      },
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'executes checkout and emits success with transaction when usecase succeeds',
      setUp: () {
        when(() => mockCheckoutUseCase.call(any())).thenAnswer(
          (_) async => const Result.success(sampleTransaction),
        );
      },
      build: () => checkoutCubit,
      act: (cubit) {
        cubit.selectQuickCash(50000);
        cubit.submitPayment();
      },
      skip: 1, // skip selectQuickCash state
      expect: () => [
        isA<CheckoutState>()
            .having((s) => s.status, 'status', CheckoutStatus.processing),
        isA<CheckoutState>()
            .having((s) => s.status, 'status', CheckoutStatus.success)
            .having((s) => s.transaction, 'transaction', equals(sampleTransaction)),
      ],
      verify: (_) {
        verify(() => mockCheckoutUseCase.call(any())).called(1);
      },
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'handles mid-transaction stock failure and emits failure with exact message',
      setUp: () {
        when(() => mockCheckoutUseCase.call(any())).thenAnswer(
          (_) async => const Result.failure(
            CheckoutFailure('Stok produk Kopi Susu tidak cukup. Tersisa 1, dibutuhkan 2.'),
          ),
        );
      },
      build: () => checkoutCubit,
      act: (cubit) {
        cubit.selectQuickCash(50000);
        cubit.submitPayment();
      },
      skip: 1,
      expect: () => [
        isA<CheckoutState>()
            .having((s) => s.status, 'status', CheckoutStatus.processing),
        isA<CheckoutState>()
            .having((s) => s.status, 'status', CheckoutStatus.failure)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Stok produk Kopi Susu tidak cukup. Tersisa 1, dibutuhkan 2.',
            ),
      ],
    );
  });
}
