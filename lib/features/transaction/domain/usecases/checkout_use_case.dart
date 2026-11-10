import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../cashier/domain/entities/cart_totals.dart';
import '../../../cashier/domain/validators/cash_calculator.dart';
import '../../../cashier/domain/validators/discount_calculator.dart';
import '../entities/checkout_params.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Coordinates business rule validation and delegates atomic execution to repository.
class CheckoutUseCase {
  final TransactionRepository _repository;
  final DiscountCalculator _discountCalculator;
  final CashCalculator _cashCalculator;

  CheckoutUseCase(
    this._repository, {
    DiscountCalculator? discountCalculator,
    CashCalculator? cashCalculator,
  })  : _discountCalculator = discountCalculator ?? const DiscountCalculator(),
        _cashCalculator = cashCalculator ?? const CashCalculator();

  Future<Result<Transaction>> call(CheckoutParams params) async {
    // 1. Validate cart is not empty
    if (params.lines.isEmpty) {
      return const Result.failure(
        ValidationFailure('Keranjang belanja kosong.'),
      );
    }

    // 2. Validate discount
    final subtotal = params.lines.fold<int>(
      0,
      (sum, line) => sum + line.lineTotal,
    );
    final discountValidation = _discountCalculator.validate(
      params.discount,
      subtotal,
    );
    if (!discountValidation.isValid) {
      return Result.failure(
        ValidationFailure(discountValidation.message ?? 'Diskon tidak valid.'),
      );
    }

    // 3. Validate cash payment
    final totals = CartTotals.compute(
      lines: params.lines,
      discount: params.discount,
      calculator: _discountCalculator,
    );
    final paymentValidation = _cashCalculator.validatePayment(
      cashReceived: params.cashReceived,
      total: totals.total,
    );
    if (!paymentValidation.isValid) {
      return Result.failure(
        ValidationFailure(paymentValidation.message ?? 'Pembayaran tidak valid.'),
      );
    }

    // 4. Delegate to repository for atomic checkout transaction
    return _repository.checkout(params);
  }
}
