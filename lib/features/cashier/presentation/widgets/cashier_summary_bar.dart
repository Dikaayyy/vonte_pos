import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_glass.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/format_rupiah.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import 'cashier_cart_view.dart';

/// Sticky summary bar anchored at the bottom of compact and medium screens.
/// Displays live cart item count and total, and opens the cart bottom sheet on tap.
class CashierSummaryBar extends StatelessWidget {
  const CashierSummaryBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Container(
          key: const Key('cashier_summary_bar'),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.gutterCompact,
            vertical: AppSpacing.xs,
          ),
          child: AppGlass(
            isAccent: true,
            borderRadius: AppRadius.borderRadiusLg,
            child: InkWell(
              onTap: () => CashierCartView.showSheet(context),
              borderRadius: AppRadius.borderRadiusLg,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    // Cart icon with count
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadius.borderRadiusSm,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.shopping_bag_outlined,
                            color: AppColors.onPrimary,
                            size: 20,
                          ),
                          if (state.isNotEmpty)
                            Positioned(
                              top: 2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: AppColors.onPrimary,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 14,
                                  minHeight: 14,
                                ),
                                child: Text(
                                  '${state.itemCount}',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    fontFeatures: AppTypography.tabularFigures,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Label & Item Count
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppStrings.viewCart,
                            style: AppTypography.title.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${state.itemCount} ${AppStrings.itemSuffix}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                              fontFeatures: AppTypography.tabularFigures,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Total
                    Text(
                      formatRupiah(state.total),
                      style: AppTypography.headlineMd.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontFeatures: AppTypography.tabularFigures,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

