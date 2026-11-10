import 'package:equatable/equatable.dart';

import '../../../../features/transaction/domain/entities/transaction.dart';
import '../../domain/entities/cart_line.dart';
import '../../domain/entities/discount.dart';

enum CheckoutStatus {
  initial,
  processing,
  success,
  failure,
}

class CheckoutState extends Equatable {
  final CheckoutStatus status;
  final List<CartLine> lines;
  final int cashierId;
  final String cashierName;
  final String? storeName;
  final String? storeAddress;
  final String? storePhone;
  final int subtotal;
  final DiscountType discountType;
  final String discountInput;
  final int discountValue;
  final int discountAmount;
  final String? discountError;
  final int total;
  final String cashReceivedInput;
  final int cashReceived;
  final String? cashError;
  final int changeAmount;
  final List<int> quickCashOptions;
  final Transaction? transaction;
  final String? errorMessage;

  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.lines = const [],
    this.cashierId = 1,
    this.cashierName = 'Kasir',
    this.storeName,
    this.storeAddress,
    this.storePhone,
    this.subtotal = 0,
    this.discountType = DiscountType.fixed,
    this.discountInput = '',
    this.discountValue = 0,
    this.discountAmount = 0,
    this.discountError,
    this.total = 0,
    this.cashReceivedInput = '',
    this.cashReceived = 0,
    this.cashError,
    this.changeAmount = 0,
    this.quickCashOptions = const [],
    this.transaction,
    this.errorMessage,
  });

  Discount get discount => discountValue > 0
      ? Discount(type: discountType, value: discountValue)
      : const Discount.none();

  bool get isValid =>
      status != CheckoutStatus.processing &&
      lines.isNotEmpty &&
      discountError == null &&
      cashReceived >= total &&
      total >= 0;

  CheckoutState copyWith({
    CheckoutStatus? status,
    List<CartLine>? lines,
    int? cashierId,
    String? cashierName,
    String? storeName,
    String? storeAddress,
    String? storePhone,
    int? subtotal,
    DiscountType? discountType,
    String? discountInput,
    int? discountValue,
    int? discountAmount,
    String? discountError,
    bool clearDiscountError = false,
    int? total,
    String? cashReceivedInput,
    int? cashReceived,
    String? cashError,
    bool clearCashError = false,
    int? changeAmount,
    List<int>? quickCashOptions,
    Transaction? transaction,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      lines: lines ?? this.lines,
      cashierId: cashierId ?? this.cashierId,
      cashierName: cashierName ?? this.cashierName,
      storeName: storeName ?? this.storeName,
      storeAddress: storeAddress ?? this.storeAddress,
      storePhone: storePhone ?? this.storePhone,
      subtotal: subtotal ?? this.subtotal,
      discountType: discountType ?? this.discountType,
      discountInput: discountInput ?? this.discountInput,
      discountValue: discountValue ?? this.discountValue,
      discountAmount: discountAmount ?? this.discountAmount,
      discountError: clearDiscountError
          ? null
          : (discountError ?? this.discountError),
      total: total ?? this.total,
      cashReceivedInput: cashReceivedInput ?? this.cashReceivedInput,
      cashReceived: cashReceived ?? this.cashReceived,
      cashError: clearCashError ? null : (cashError ?? this.cashError),
      changeAmount: changeAmount ?? this.changeAmount,
      quickCashOptions: quickCashOptions ?? this.quickCashOptions,
      transaction: transaction ?? this.transaction,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        lines,
        cashierId,
        cashierName,
        storeName,
        storeAddress,
        storePhone,
        subtotal,
        discountType,
        discountInput,
        discountValue,
        discountAmount,
        discountError,
        total,
        cashReceivedInput,
        cashReceived,
        cashError,
        changeAmount,
        quickCashOptions,
        transaction,
        errorMessage,
      ];
}

