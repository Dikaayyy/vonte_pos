import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/utils/format_rupiah.dart';
import '../../../../core/widgets/dashed_divider.dart';
import '../../domain/entities/transaction.dart';

/// Renders a thermal-paper style receipt card for a completed transaction.
///
/// Follows DESIGN.md rules:
/// - Solid white surface-card, strictly NO glassmorphism / NO blur.
/// - Tabular figures on all numbers and prices.
/// - Dashed dividers separating sections.
/// - Indented add-on line items.
/// - Right-aligned money amounts.
class ReceiptView extends StatelessWidget {
  final Transaction transaction;
  final String? customFooter;

  const ReceiptView({super.key, required this.transaction, this.customFooter});

  @override
  Widget build(BuildContext context) {
    final tabularStyle = const TextStyle(
      fontFeatures: [FontFeature.tabularFigures()],
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.borderHairline),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Store Header
          Text(
            transaction.storeName.isNotEmpty
                ? transaction.storeName
                : AppStrings.appName,
            textAlign: TextAlign.center,
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (transaction.storeAddress.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              transaction.storeAddress,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
          if (transaction.storePhone.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              transaction.storePhone,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: AppColors.onSurfaceVariant,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.md),
          const DashedDivider(),
          const SizedBox(height: AppSpacing.md),

          // 2. Transaction Metadata
          _buildMetaRow(
            label: AppStrings.invoiceNoLabel,
            value: transaction.invoiceNo,
            valueStyle: AppTypography.bodySm.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildMetaRow(
            label: AppStrings.dateLabel,
            value: formatDateTime(transaction.createdAt),
            valueStyle: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildMetaRow(
            label: AppStrings.cashierLabel,
            value: transaction.cashierName,
            valueStyle: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          const DashedDivider(),
          const SizedBox(height: AppSpacing.md),

          // 3. Purchased Items & Add-ons
          ...transaction.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: AppTypography.bodyMd.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              '${item.qty} x ${formatRupiah(item.unitPrice)}',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontFeatures: [
                                  const FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        formatRupiah(item.lineTotal),
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  // Indented Add-ons
                  if (item.addons.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.md,
                        top: AppSpacing.xs,
                      ),
                      child: Column(
                        children: item.addons.map((addon) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '+ ${addon.addonName} (${addon.qty}x ${formatRupiah(addon.addonPrice)})',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      fontFeatures: [
                                        const FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ),
                                Text(
                                  formatRupiah(addon.lineTotal),
                                  style: AppTypography.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurfaceVariant,
                                    fontFeatures: [
                                      const FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            );
          }),

          const SizedBox(height: AppSpacing.xs),
          const DashedDivider(),
          const SizedBox(height: AppSpacing.md),

          // 4. Financial Summary
          _buildSummaryRow(
            label: AppStrings.subtotal,
            value: formatRupiah(transaction.subtotal),
            tabularStyle: tabularStyle,
          ),
          if (transaction.discountAmount > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            _buildSummaryRow(
              label: AppStrings.discount,
              value: '-${formatRupiah(transaction.discountAmount)}',
              tabularStyle: tabularStyle,
              valueColor: AppColors.error,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          _buildSummaryRow(
            label: AppStrings.total,
            value: formatRupiah(transaction.total),
            tabularStyle: tabularStyle,
            isTotal: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildSummaryRow(
            label:
                '${AppStrings.cashPayment} (${AppStrings.cashReceivedLabel})',
            value: formatRupiah(transaction.cashReceived),
            tabularStyle: tabularStyle,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildSummaryRow(
            label: AppStrings.changeLabel,
            value: formatRupiah(transaction.changeAmount),
            tabularStyle: tabularStyle,
            valueColor: AppColors.success,
            isBold: true,
          ),

          const SizedBox(height: AppSpacing.md),
          const DashedDivider(),
          const SizedBox(height: AppSpacing.md),

          // 5. Store Footer Note
          Text(
            customFooter?.isNotEmpty == true
                ? customFooter!
                : AppStrings.defaultStoreFooter,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              color: AppColors.onSurfaceMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow({
    required String label,
    required String value,
    required TextStyle valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(value, style: valueStyle),
      ],
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    required TextStyle tabularStyle,
    Color? valueColor,
    bool isTotal = false,
    bool isBold = false,
  }) {
    final style = isTotal
        ? AppTypography.headlineMd.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          )
        : AppTypography.bodyMd.copyWith(
            fontWeight: (isBold || isTotal) ? FontWeight.w700 : FontWeight.w500,
            color: valueColor ?? AppColors.onSurface,
          );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTypography.headlineMd.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                )
              : AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
        ),
        Text(value, style: style.merge(tabularStyle)),
      ],
    );
  }
}
