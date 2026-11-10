import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_glass.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/format_rupiah.dart';
import '../../../../core/widgets/qty_stepper.dart';
import '../../../../core/widgets/stock_badge.dart';
import '../../../addon/domain/entities/addon.dart';
import '../../../product/domain/entities/product.dart';

/// Modal bottom sheet for customizing product add-ons and quantity.
///
/// Features:
/// - Product header with base price.
/// - Product quantity stepper with remaining stock bounds.
/// - Available add-on rows with extra price, stock status, and checkbox toggles.
/// - Disabled add-on rows with 'Habis' badge when stock is exhausted.
/// - Live computed subtotal.
/// - 'Tambah ke keranjang' primary action with light haptic feedback.
class CashierAddonSheet extends StatefulWidget {
  final Product product;
  final List<Addon> availableAddons;
  final int maxProductQty;
  final Map<int, int> addonRemainingStocks;
  final void Function(List<Addon> selectedAddons, int qty) onConfirm;

  const CashierAddonSheet({
    super.key,
    required this.product,
    required this.availableAddons,
    required this.maxProductQty,
    this.addonRemainingStocks = const {},
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    required Product product,
    required List<Addon> availableAddons,
    required int maxProductQty,
    Map<int, int> addonRemainingStocks = const {},
    required void Function(List<Addon> selectedAddons, int qty) onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CashierAddonSheet(
        product: product,
        availableAddons: availableAddons,
        maxProductQty: maxProductQty,
        addonRemainingStocks: addonRemainingStocks,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<CashierAddonSheet> createState() => _CashierAddonSheetState();
}

class _CashierAddonSheetState extends State<CashierAddonSheet> {
  int _qty = 1;
  final Set<int> _selectedAddonIds = {};

  @override
  void initState() {
    super.initState();
    _qty = 1;
  }

  int get _addonsUnitPrice {
    var sum = 0;
    for (final addon in widget.availableAddons) {
      if (_selectedAddonIds.contains(addon.id)) {
        sum += addon.price;
      }
    }
    return sum;
  }

  int get _liveSubtotal => (widget.product.price + _addonsUnitPrice) * _qty;

  bool _isAddonExhausted(Addon addon) {
    final remaining = widget.addonRemainingStocks[addon.id] ?? addon.stock;
    return remaining <= 0;
  }

  void _toggleAddon(Addon addon) {
    if (_isAddonExhausted(addon)) return;
    setState(() {
      if (_selectedAddonIds.contains(addon.id)) {
        _selectedAddonIds.remove(addon.id);
      } else {
        _selectedAddonIds.add(addon.id);
      }
    });
  }

  void _submit() {
    HapticFeedback.lightImpact();
    final selectedList = widget.availableAddons
        .where((a) => _selectedAddonIds.contains(a.id))
        .toList();
    widget.onConfirm(selectedList, _qty);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final maxQty = widget.maxProductQty > 0 ? widget.maxProductQty : 1;

    return AppGlass(
      isStrong: true,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.xl),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: AppTypography.headlineMd.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formatRupiah(widget.product.price),
                            style: AppTypography.price.copyWith(
                              color: AppColors.primary,
                              fontFeatures: AppTypography.tabularFigures,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.onSurfaceVariant,
                      tooltip: AppStrings.close,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(color: AppColors.borderHairline, height: 1),

              // 3. Scrollable content: Qty + Addon list
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.gutterCompact,
                    vertical: AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quantity Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.orderQuantityLabel,
                                style: AppTypography.title.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${AppStrings.stockLabelPrefix} ${widget.maxProductQty}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontFeatures: AppTypography.tabularFigures,
                                ),
                              ),
                            ],
                          ),
                          QtyStepper(
                            value: _qty,
                            min: 1,
                            max: maxQty,
                            disabledReason: _qty >= maxQty
                                ? AppStrings.maxStockReached
                                : null,
                            onChanged: (newQty) {
                              setState(() {
                                _qty = newQty;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.lg),
                      const Divider(color: AppColors.borderHairline, height: 1),
                      const SizedBox(height: AppSpacing.md),

                      // Addon Section Title
                      Text(
                        AppStrings.selectAddonPrompt,
                        style: AppTypography.title.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Addon List
                      if (widget.availableAddons.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          child: Text(
                            AppStrings.noAddonsAvailable,
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        )
                      else
                        ...widget.availableAddons.map((addon) {
                          final isExhausted = _isAddonExhausted(addon);
                          final isSelected = _selectedAddonIds.contains(addon.id);
                          final remaining =
                              widget.addonRemainingStocks[addon.id] ?? addon.stock;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Material(
                              color: isSelected
                                  ? AppColors.primarySoft
                                  : AppColors.surfaceCard,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.borderRadiusMd,
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.borderHairline,
                                  width: 1,
                                ),
                              ),
                              child: InkWell(
                                onTap: isExhausted
                                    ? null
                                    : () => _toggleAddon(addon),
                                borderRadius: AppRadius.borderRadiusMd,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.md,
                                  ),
                                  child: Row(
                                    children: [
                                      // Checkbox
                                      Checkbox(
                                        value: isSelected,
                                        activeColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        onChanged: isExhausted
                                            ? null
                                            : (_) => _toggleAddon(addon),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),

                                      // Addon Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              addon.name,
                                              style: AppTypography.bodyMd.copyWith(
                                                color: isExhausted
                                                    ? AppColors.onSurfaceMuted
                                                    : AppColors.onSurface,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${AppStrings.stockLabelPrefix} $remaining',
                                              style: AppTypography.caption.copyWith(
                                                color: AppColors.onSurfaceVariant,
                                                fontFeatures: AppTypography
                                                    .tabularFigures,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Price or Out of stock badge
                                      if (isExhausted)
                                        const StockBadge.outOfStock()
                                      else
                                        Text(
                                          addon.price == 0
                                              ? AppStrings.freePriceLabel
                                              : '+${formatRupiah(addon.price)}',
                                          style: AppTypography.price.copyWith(
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.onSurface,
                                            fontWeight: FontWeight.w700,
                                            fontFeatures:
                                                AppTypography.tabularFigures,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),

              const Divider(color: AppColors.borderHairline, height: 1),

              // 4. Footer with Live Subtotal and Add to Cart Button
              Padding(
                padding: const EdgeInsets.all(AppSpacing.gutterCompact),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.subtotal,
                          style: AppTypography.title.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          formatRupiah(_liveSubtotal),
                          style: AppTypography.headlineMd.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontFeatures: AppTypography.tabularFigures,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      text: AppStrings.addToCart,
                      variant: AppButtonVariant.primary,
                      isLarge: true,
                      fullWidth: true,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
