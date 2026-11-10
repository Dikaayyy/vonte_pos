import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_glass.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/format_rupiah.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/inline_error.dart';
import '../../../addon/presentation/cubit/addon_cubit.dart';
import '../../../product/presentation/cubit/product_cubit.dart';
import '../../domain/entities/cart_line.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import 'cashier_cart_line_item.dart';

/// Cart content view, usable both as a slide-up bottom sheet (compact/medium)
/// and as a fixed right panel (expanded tablet).
class CashierCartView extends StatelessWidget {
  final bool isSheet;
  final VoidCallback? onClose;

  const CashierCartView({
    super.key,
    this.isSheet = false,
    this.onClose,
  });

  /// Opens the cart as a modal bottom sheet.
  static Future<void> showSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.85,
        child: AppGlass(
          isStrong: true,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
          child: CashierCartView(
            isSheet: true,
            onClose: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
    );
  }

  int _calculateMaxAllowedForLine(
    BuildContext context,
    CartLine line,
    List<CartLine> cartLines,
  ) {
    // 1. Product stock check
    int productStock = 999;
    try {
      final productState = context.read<ProductCubit>().state;
      for (final p in productState.products) {
        if (p.id == line.productId) {
          productStock = p.stock;
          break;
        }
      }
    } catch (_) {}

    var otherProductUsage = 0;
    for (final item in cartLines) {
      if (item.productId == line.productId && !item.hasSameIdentity(line)) {
        otherProductUsage += item.qty;
      }
    }
    var maxForLine = max(1, productStock - otherProductUsage);

    // 2. Addon stock checks
    if (line.addons.isNotEmpty) {
      try {
        final addonState = context.read<AddonCubit>().state;
        for (final attached in line.addons) {
          int addonStock = 999;
          for (final a in addonState.addons) {
            if (a.id == attached.id) {
              addonStock = a.stock;
              break;
            }
          }
          final countInLine =
              line.addons.where((a) => a.id == attached.id).length;
          var otherAddonUsage = 0;
          for (final item in cartLines) {
            if (!item.hasSameIdentity(line)) {
              final cnt = item.addons.where((a) => a.id == attached.id).length;
              otherAddonUsage += item.qty * cnt;
            }
          }
          final availableForAddon =
              max(0, addonStock - otherAddonUsage) ~/ countInLine;
          maxForLine = min(maxForLine, availableForAddon);
        }
      } catch (_) {}
    }

    return max(line.qty, maxForLine);
  }

  void _onPayPressed(BuildContext context) {
    if (isSheet) {
      Navigator.of(context).pop();
    }
    Navigator.of(context).pushNamed(AppRoutes.checkout);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final cartCubit = context.read<CartCubit>();

        return SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Drag handle if sheet
              if (isSheet)
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(
                      top: AppSpacing.sm,
                      bottom: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.onSurfaceMuted.withValues(alpha: 0.3),
                      borderRadius: AppRadius.borderRadiusFull,
                    ),
                  ),
                ),

              // 2. Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.gutterCompact,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: AppRadius.borderRadiusSm,
                      ),
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      AppStrings.cartTitle,
                      style: AppTypography.headlineMd.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    if (state.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: AppRadius.borderRadiusFull,
                        ),
                        child: Text(
                          '${state.itemCount}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontFeatures: AppTypography.tabularFigures,
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (isSheet)
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        color: AppColors.onSurfaceVariant,
                        tooltip: AppStrings.close,
                        onPressed: onClose ?? () => Navigator.of(context).pop(),
                      ),
                  ],
                ),
              ),

              const Divider(color: AppColors.borderHairline, height: 1),

              // 3. Inline Error if present
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.gutterCompact,
                    AppSpacing.sm,
                    AppSpacing.gutterCompact,
                    0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InlineError(
                          message: state.errorMessage!,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16),
                        color: AppColors.error,
                        tooltip: AppStrings.close,
                        onPressed: () => cartCubit.clearError(),
                      ),
                    ],
                  ),
                ),

              // 4. Cart Items List / Empty State
              Expanded(
                child: state.isEmpty
                    ? const Center(
                        child: EmptyState(
                          title: AppStrings.emptyCartTitle,
                          message: AppStrings.emptyCartSubtitle,
                          icon: Icons.shopping_cart_outlined,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.gutterCompact),
                        itemCount: state.items.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final line = state.items[index];
                          final maxAllowed = _calculateMaxAllowedForLine(
                            context,
                            line,
                            state.items,
                          );

                          return CashierCartLineItem(
                            line: line,
                            maxAllowedQty: maxAllowed,
                            onQtyChanged: (newQty) {
                              cartCubit.updateQuantity(line, newQty);
                            },
                            onRemove: () {
                              cartCubit.removeLine(line);
                            },
                          );
                        },
                      ),
              ),

              const Divider(color: AppColors.borderHairline, height: 1),

              // 5. Cart Summary & Pay Footer
              Container(
                padding: const EdgeInsets.all(AppSpacing.gutterCompact),
                color: AppColors.surfaceCard,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Subtotal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.subtotal,
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          formatRupiah(state.subtotal),
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                            fontFeatures: AppTypography.tabularFigures,
                          ),
                        ),
                      ],
                    ),

                    // Discount (if any)
                    if (state.discountAmount > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.discount,
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '-${formatRupiah(state.discountAmount)}',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                              fontFeatures: AppTypography.tabularFigures,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xs),

                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.total,
                          style: AppTypography.title.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          formatRupiah(state.total),
                          style: AppTypography.headlineMd.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontFeatures: AppTypography.tabularFigures,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Bayar Action Button
                    AppButton(
                      text: AppStrings.pay,
                      variant: AppButtonVariant.primary,
                      isLarge: true,
                      fullWidth: true,
                      onPressed:
                          state.isNotEmpty ? () => _onPayPressed(context) : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
