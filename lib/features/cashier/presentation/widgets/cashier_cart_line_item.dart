import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/format_rupiah.dart';
import '../../../../core/widgets/qty_stepper.dart';
import '../../domain/entities/cart_line.dart';

/// Solid list row for an individual item in the shopping cart.
/// Complies with DESIGN.md rule: NO BackdropFilter inside scrolling items.
class CashierCartLineItem extends StatelessWidget {
  final CartLine line;
  final int maxAllowedQty;
  final ValueChanged<int> onQtyChanged;
  final VoidCallback onRemove;

  const CashierCartLineItem({
    super.key,
    required this.line,
    required this.maxAllowedQty,
    required this.onQtyChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasAddons = line.addons.isNotEmpty;
    final isMaxReached = line.qty >= maxAllowedQty;
    final disabledReason = isMaxReached
        ? '${AppStrings.stockInsufficient} ${AppStrings.stockRemainingPrefix} $maxAllowedQty.'
        : null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.borderHairline, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Product Name & Line Total (Right-aligned)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  line.productName,
                  style: AppTypography.title.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                formatRupiah(line.lineTotal),
                textAlign: TextAlign.right,
                style: AppTypography.price.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontFeatures: AppTypography.tabularFigures,
                ),
              ),
            ],
          ),

          // Row 2: Add-on Captions
          if (hasAddons) ...[
            const SizedBox(height: 2),
            Text(
              '+ ${line.addons.map((a) => a.name).join(', ')}',
              style: AppTypography.caption.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: AppSpacing.sm),

          // Row 3: QtyStepper & Remove Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: QtyStepper(
                  value: line.qty,
                  min: 1,
                  max: maxAllowedQty,
                  disabledReason: disabledReason,
                  compact: true,
                  onChanged: onQtyChanged,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
                tooltip: AppStrings.delete,
                constraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),
                onPressed: onRemove,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
