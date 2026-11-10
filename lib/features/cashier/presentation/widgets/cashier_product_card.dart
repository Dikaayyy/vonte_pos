import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/format_rupiah.dart';
import '../../../product/data/services/photo_storage.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/presentation/widgets/product_image_view.dart';

/// Solid product card for the Cashier grid.
///
/// Complies with DESIGN.md specifications:
/// - Solid white surface (AppCard), NO BackdropFilter inside scrolling items.
/// - Photo on top (square crop with neutral placeholder when missing).
/// - Name (max 2 lines) and price in `price` style (#0F766E).
/// - 5 distinct visual states:
///   1. Normal: tap adds one unit.
///   2. Has add-ons: topping badge in corner, tap opens add-on sheet.
///   3. Low stock: warning badge 'Sisa X'.
///   4. Out of stock: dimmed, 'Habis' badge, not tappable.
///   5. Stock full in cart: not tappable, inline badge/hint 'Stok sudah di keranjang'.
class CashierProductCard extends StatelessWidget {
  final Product product;
  final int unitsInCart;
  final VoidCallback? onTap;
  final PhotoStorage? photoStorage;

  const CashierProductCard({
    super.key,
    required this.product,
    this.unitsInCart = 0,
    this.onTap,
    this.photoStorage,
  });

  bool get isOutOfStock => product.isOutOfStock;
  bool get isCartStockFull =>
      !isOutOfStock && product.stock > 0 && unitsInCart >= product.stock;
  bool get isTappable => !isOutOfStock && !isCartStockFull && onTap != null;

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Photo area with overlay badges (Flexible to fit any card aspect ratio)
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ProductImageView(
                photoPath: product.photoPath,
                productName: product.name,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
                photoStorage: photoStorage,
              ),
              // Status Badge (Top-Left)
              Positioned(
                top: AppSpacing.xs,
                left: AppSpacing.xs,
                child: _buildStatusBadge(),
              ),
              // Addon Badge (Top-Right)
              if (product.hasAddons)
                Positioned(
                  top: AppSpacing.xs,
                  right: AppSpacing.xs,
                  child: _buildAddonBadge(),
                ),
            ],
          ),
        ),

        // 2. Info area
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (product.categoryName != null &&
                  product.categoryName!.trim().isNotEmpty)
                Text(
                  product.categoryName!,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              Text(
                product.name,
                style: AppTypography.title.copyWith(
                  color: isOutOfStock || isCartStockFull
                      ? AppColors.onSurfaceVariant
                      : AppColors.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                formatRupiah(product.price),
                style: AppTypography.price.copyWith(
                  color: isOutOfStock
                      ? AppColors.onSurfaceMuted
                      : AppColors.primary,
                  fontSize: 13,
                  fontFeatures: AppTypography.tabularFigures,
                ),
              ),
              const SizedBox(height: 2),
              _buildStockIndicator(),
            ],
          ),
        ),
      ],
    );

    if (isOutOfStock || isCartStockFull) {
      cardContent = Opacity(
        opacity: isOutOfStock ? 0.55 : 0.70,
        child: cardContent,
      );
    }

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: isTappable ? onTap : null,
      child: cardContent,
    );
  }

  Widget _buildStatusBadge() {
    if (isOutOfStock) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.errorSoft,
          borderRadius: AppRadius.borderRadiusFull,
          border: Border.all(color: AppColors.error, width: 1),
        ),
        child: Text(
          AppStrings.outOfStockBadge,
          style: AppTypography.caption.copyWith(
            color: AppColors.error,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    if (isCartStockFull) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.warningSoft,
          borderRadius: AppRadius.borderRadiusFull,
          border: Border.all(color: AppColors.warning, width: 1),
        ),
        child: Text(
          AppStrings.stockAlreadyInCart,
          style: AppTypography.caption.copyWith(
            color: AppColors.warning,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    if (product.hasLowStock) {
      final remaining = product.stock - unitsInCart;
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.warningSoft,
          borderRadius: AppRadius.borderRadiusFull,
          border: Border.all(color: AppColors.warning, width: 1),
        ),
        child: Text(
          '${AppStrings.lowStockPrefix} $remaining',
          style: AppTypography.caption.copyWith(
            color: AppColors.warning,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildAddonBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: AppRadius.borderRadiusFull,
        border: Border.all(
          color: AppColors.primary,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.tune_rounded,
            size: 13,
            color: AppColors.primary,
          ),
          const SizedBox(width: 3),
          Text(
            '+${product.addonIds.length}',
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontFeatures: AppTypography.tabularFigures,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockIndicator() {
    if (isOutOfStock) {
      return Text(
        AppStrings.stockExhaustedGeneral,
        style: AppTypography.caption.copyWith(
          color: AppColors.error,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    if (isCartStockFull) {
      return Text(
        AppStrings.stockAlreadyInCart,
        style: AppTypography.caption.copyWith(
          color: AppColors.warning,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final remaining = product.stock - unitsInCart;
    return Text(
      '${AppStrings.stockLabelPrefix} $remaining',
      style: AppTypography.caption.copyWith(
        color: product.hasLowStock
            ? AppColors.warning
            : AppColors.onSurfaceVariant,
        fontWeight: FontWeight.w500,
        fontFeatures: AppTypography.tabularFigures,
      ),
    );
  }
}
