import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../features/transaction/domain/entities/checkout_params.dart';
import '../../../../features/transaction/domain/usecases/checkout_use_case.dart';
import '../../domain/entities/cart_line.dart';
import '../../domain/entities/discount.dart';
import '../../domain/validators/cash_calculator.dart';
import '../../domain/validators/discount_calculator.dart';
import '../../domain/validators/quick_cash_calculator.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final CheckoutUseCase checkoutUseCase;
  final DiscountCalculator _discountCalculator;
  final CashCalculator _cashCalculator;
  final QuickCashCalculator _quickCashCalculator;

  CheckoutCubit({
    required this.checkoutUseCase,
    DiscountCalculator? discountCalculator,
    CashCalculator? cashCalculator,
    QuickCashCalculator? quickCashCalculator,
  })  : _discountCalculator = discountCalculator ?? const DiscountCalculator(),
        _cashCalculator = cashCalculator ?? const CashCalculator(),
        _quickCashCalculator =
            quickCashCalculator ?? const QuickCashCalculator(),
        super(const CheckoutState());

  /// Initializes the checkout state with cart lines, cashier identity, and store details.
  void init({
    required List<CartLine> lines,
    required int cashierId,
    required String cashierName,
    String? storeName,
    String? storeAddress,
    String? storePhone,
    Discount? initialDiscount,
  }) {
    final subtotal = lines.fold<int>(0, (sum, line) => sum + line.lineTotal);

    DiscountType discountType = DiscountType.fixed;
    String discountInput = '';
    int discountValue = 0;
    int discountAmount = 0;

    if (initialDiscount != null && !initialDiscount.isNone) {
      discountType = initialDiscount.type;
      discountValue = initialDiscount.value;
      discountInput = discountValue.toString();
      final validation = _discountCalculator.validate(initialDiscount, subtotal);
      if (validation.isValid) {
        discountAmount = _discountCalculator.calculateDiscountAmount(
          initialDiscount,
          subtotal,
        );
      }
    }

    final total = (subtotal - discountAmount).clamp(0, subtotal);
    final quickCash = _quickCashCalculator.calculateOptions(total);

    emit(state.copyWith(
      status: CheckoutStatus.initial,
      lines: lines,
      cashierId: cashierId,
      cashierName: cashierName,
      storeName: storeName,
      storeAddress: storeAddress,
      storePhone: storePhone,
      subtotal: subtotal,
      discountType: discountType,
      discountInput: discountInput,
      discountValue: discountValue,
      discountAmount: discountAmount,
      clearDiscountError: true,
      total: total,
      cashReceivedInput: '',
      cashReceived: 0,
      cashError: AppStrings.paymentShortage,
      changeAmount: 0,
      quickCashOptions: quickCash,
      clearErrorMessage: true,
    ));
  }

  /// Sets the discount type (fixed or percent) and re-evaluates validation.
  void setDiscountType(DiscountType type) {
    if (state.discountType == type) return;
    _recalculate(discountType: type);
  }

  /// Updates the discount input string and recalculates totals and validations.
  void setDiscountInput(String input) {
    _recalculate(discountInput: input);
  }

  /// Sets cash received via manual input.
  void setCashReceivedInput(String input) {
    final clean = input.replaceAll(RegExp(r'[^0-9]'), '');
    final cash = int.tryParse(clean) ?? 0;
    _recalculate(
      cashReceivedInput: input,
      cashReceived: cash,
    );
  }

  /// Sets cash received directly from a quick-cash banknote chip or "Uang pas".
  void selectQuickCash(int amount) {
    _recalculate(
      cashReceivedInput: amount.toString(),
      cashReceived: amount,
    );
  }

  void _recalculate({
    DiscountType? discountType,
    String? discountInput,
    String? cashReceivedInput,
    int? cashReceived,
  }) {
    final effectiveType = discountType ?? state.discountType;
    final effectiveDiscountInput = discountInput ?? state.discountInput;
    final cleanDiscountInput = effectiveDiscountInput.trim();

    int discountValue = 0;
    int discountAmount = 0;
    String? discountError;

    if (cleanDiscountInput.isNotEmpty) {
      final parsed = int.tryParse(cleanDiscountInput);
      if (parsed == null) {
        discountError = 'Diskon harus berupa angka valid.';
      } else if (parsed < 0) {
        discountError = effectiveType == DiscountType.percent
            ? AppStrings.discountPercentOutOfRange
            : AppStrings.discountFixedNegative;
      } else {
        discountValue = parsed;
        final discount = Discount(type: effectiveType, value: discountValue);
        final validation = _discountCalculator.validate(discount, state.subtotal);
        if (!validation.isValid) {
          discountError = validation.message;
        } else {
          discountAmount = _discountCalculator.calculateDiscountAmount(
            discount,
            state.subtotal,
          );
        }
      }
    }

    final total = discountError != null
        ? state.subtotal
        : (state.subtotal - discountAmount).clamp(0, state.subtotal);

    final quickCash = _quickCashCalculator.calculateOptions(total);

    final effectiveCash = cashReceived ??
        (int.tryParse(
              (cashReceivedInput ?? state.cashReceivedInput)
                  .replaceAll(RegExp(r'[^0-9]'), ''),
            ) ??
            0);

    final paymentResult = _cashCalculator.validatePayment(
      cashReceived: effectiveCash,
      total: total,
    );

    final cashError = paymentResult.isValid ? null : AppStrings.paymentShortage;
    final changeAmount = paymentResult.isValid ? paymentResult.change : 0;

    emit(state.copyWith(
      discountType: effectiveType,
      discountInput: effectiveDiscountInput,
      discountValue: discountValue,
      discountAmount: discountAmount,
      discountError: discountError,
      clearDiscountError: discountError == null,
      total: total,
      cashReceivedInput: cashReceivedInput ?? state.cashReceivedInput,
      cashReceived: effectiveCash,
      cashError: cashError,
      clearCashError: cashError == null,
      changeAmount: changeAmount,
      quickCashOptions: quickCash,
      clearErrorMessage: true,
    ));
  }

  /// Submits the checkout transaction atomically via [CheckoutUseCase].
  Future<void> submitPayment() async {
    if (!state.isValid) return;

    emit(state.copyWith(
      status: CheckoutStatus.processing,
      clearErrorMessage: true,
    ));

    final discount = state.discountValue > 0
        ? Discount(type: state.discountType, value: state.discountValue)
        : const Discount.none();

    final params = CheckoutParams(
      lines: state.lines,
      discount: discount,
      cashReceived: state.cashReceived,
      cashierId: state.cashierId,
      cashierName: state.cashierName,
      storeName: state.storeName,
      storeAddress: state.storeAddress,
      storePhone: state.storePhone,
    );

    final result = await checkoutUseCase(params);

    result.fold(
      onSuccess: (transaction) {
        emit(state.copyWith(
          status: CheckoutStatus.success,
          transaction: transaction,
        ));
      },
      onFailure: (failure) {
        emit(state.copyWith(
          status: CheckoutStatus.failure,
          errorMessage: failure.message,
        ));
      },
    );
  }
}

