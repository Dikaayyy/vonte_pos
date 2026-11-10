import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_strings.dart';

/// Result of cash payment verification.
class CashPaymentResult extends Equatable {
  final bool isValid;
  final int change;
  final int shortage;
  final String? message;

  const CashPaymentResult.valid({required this.change})
      : isValid = true,
        shortage = 0,
        message = null;

  const CashPaymentResult.invalid({
    required this.shortage,
    required String this.message,
  })  : isValid = false,
        change = 0;

  @override
  List<Object?> get props => [isValid, change, shortage, message];
}

/// Calculates and validates cash payment transactions.
///
/// Rule: Cash received must be >= total. Change = cash received - total.
class CashCalculator {
  const CashCalculator();

  /// Validates cash payment against the total transaction amount.
  CashPaymentResult validatePayment({
    required int cashReceived,
    required int total,
  }) {
    if (cashReceived < 0 || total < 0) {
      return const CashPaymentResult.invalid(
        shortage: 0,
        message: 'Nominal pembayaran tidak valid.',
      );
    }

    if (cashReceived < total) {
      final shortage = total - cashReceived;
      return CashPaymentResult.invalid(
        shortage: shortage,
        message: AppStrings.paymentInsufficient,
      );
    }

    final change = cashReceived - total;
    return CashPaymentResult.valid(change: change);
  }

  /// Calculates change: `cashReceived - total`.
  /// Throws [ArgumentError] if [cashReceived] < [total].
  int calculateChange({
    required int cashReceived,
    required int total,
  }) {
    if (cashReceived < total) {
      throw ArgumentError(
        'Uang diterima ($cashReceived) kurang dari total ($total).',
      );
    }
    return cashReceived - total;
  }
}

