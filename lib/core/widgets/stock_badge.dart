import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Variant for [StockBadge] styling.
enum StockBadgeVariant {
  /// Warning style for low stock ('Sisa X').
  lowStock,

  /// Error style when stock is completely exhausted ('Habis').
  outOfStock,

  /// Warning style when cart has reserved all available stock.
  cartFull,

  /// Custom badge with caller-provided colors and text.
  custom,
}

/// Shared semantic pill badge for stock states across the cashier,
/// product catalog, and add-on management.
///
/// Complies with DESIGN.md:
/// - Rounded full pill shape (`AppRadius.borderRadiusFull`).
/// - Semantic colors only: `warningSoft`/`warning` for low stock and cart full,
///   `errorSoft`/`error` for out of stock.
/// - Tabular numerals for remaining counts.
class StockBadge extends StatelessWidget {
  final StockBadgeVariant variant;
  final String? label;
  final int? stock;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  /// Default constructor that automatically selects the appropriate badge:
  /// - `stock <= 0`: out of stock ('Habis')
  /// - `stock > 0 && stock <= threshold`: low stock ('Sisa X')
  /// - `stock > threshold`: renders [SizedBox.shrink]
  factory StockBadge({
    Key? key,
    required int stock,
    int threshold = AppConstants.lowStockThreshold,
  }) {
    if (stock <= 0) {
      return StockBadge.outOfStock(key: key);
    }
    if (stock <= threshold) {
      return StockBadge.lowStock(key: key, stock: stock);
    }
    return StockBadge._empty(key: key);
  }

  /// Warning badge indicating remaining stock count ('Sisa X').
  const StockBadge.lowStock({
    super.key,
    required int this.stock,
  })  : variant = StockBadgeVariant.lowStock,
        label = null,
        backgroundColor = AppColors.warningSoft,
        textColor = AppColors.warning,
        borderColor = AppColors.warning;

  /// Error badge indicating stock is completely exhausted ('Habis').
  const StockBadge.outOfStock({super.key})
      : variant = StockBadgeVariant.outOfStock,
        label = AppStrings.outOfStockBadge,
        stock = null,
        backgroundColor = AppColors.errorSoft,
        textColor = AppColors.error,
        borderColor = AppColors.error;

  /// Warning badge indicating cart already holds all available stock.
  const StockBadge.cartFull({super.key})
      : variant = StockBadgeVariant.cartFull,
        label = AppStrings.stockAlreadyInCart,
        stock = null,
        backgroundColor = AppColors.warningSoft,
        textColor = AppColors.warning,
        borderColor = AppColors.warning;

  /// Custom badge with caller-specified label and colors.
  const StockBadge.custom({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    Color? borderColor,
  })  : variant = StockBadgeVariant.custom,
        stock = null,
        borderColor = borderColor ?? textColor;

  const StockBadge._empty({super.key})
      : variant = StockBadgeVariant.custom,
        label = '',
        stock = null,
        backgroundColor = Colors.transparent,
        textColor = Colors.transparent,
        borderColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    final displayText = label ??
        (stock != null ? '${AppStrings.lowStockPrefix} $stock' : '');
    if (displayText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.borderRadiusFull,
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Text(
        displayText,
        style: AppTypography.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontFeatures: AppTypography.tabularFigures,
        ),
      ),
    );
  }
}
