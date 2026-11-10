import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_glass.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/inline_error.dart';
import '../../../addon/domain/entities/addon.dart';
import '../../../addon/presentation/cubit/addon_cubit.dart';
import '../../../category/presentation/cubit/category_cubit.dart';
import '../../../product/data/services/photo_storage.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/presentation/cubit/product_cubit.dart';
import '../../../product/presentation/cubit/product_state.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../widgets/cashier_addon_sheet.dart';
import '../widgets/cashier_cart_view.dart';
import '../widgets/cashier_product_card.dart';
import '../widgets/cashier_summary_bar.dart';

/// Main Cashier View (Tab 1 in AppShell).
///
/// Features:
/// - Search bar with filter as user types and clear button.
/// - Category chips filter row with 'Semua' as first option.
/// - Responsive grid:
///   - Compact (< 600dp): 2 columns, sticky summary bar.
///   - Medium (600-839dp): 3 columns, sticky summary bar.
///   - Expanded (>= 840dp): 4 columns, fixed cart panel on right.
/// - Solid product cards with all DESIGN.md states:
///   normal, has addons, low stock, out of stock, stock full in cart.
/// - Tap without addons adds 1 unit directly with light haptic feedback.
/// - Tap with addons opens CashierAddonSheet.
/// - Inline stock validation messages.
/// - NO BackdropFilter inside scrolling items.
class CashierView extends StatefulWidget {
  final PhotoStorage? photoStorage;

  const CashierView({
    super.key,
    this.photoStorage,
  });

  @override
  State<CashierView> createState() => _CashierViewState();
}

class _CashierViewState extends State<CashierView> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onProductTapped(
    BuildContext context,
    Product product,
    int unitsInCart,
    CartState cartState,
  ) {
    final cartCubit = context.read<CartCubit>();

    if (!product.hasAddons) {
      // Tap without add-ons: directly add 1 unit with light haptic feedback
      HapticFeedback.lightImpact();
      cartCubit.addProduct(product, qty: 1);
      return;
    }

    // Tap with add-ons: open add-on sheet
    final maxProductQty = max(1, product.stock - unitsInCart);
    final addonState = context.read<AddonCubit?>()?.state;
    final allAddons = addonState?.addons ?? <Addon>[];
    final availableAddons = allAddons
        .where((a) => product.addonIds.contains(a.id) && !a.isDeleted)
        .toList();

    // Compute remaining stock per addon based on current cart usage
    final addonRemainingStocks = <int, int>{};
    for (final addon in availableAddons) {
      var addonUsageInCart = 0;
      for (final line in cartState.items) {
        final count = line.addons.where((a) => a.id == addon.id).length;
        addonUsageInCart += line.qty * count;
      }
      addonRemainingStocks[addon.id] = max(0, addon.stock - addonUsageInCart);
    }

    CashierAddonSheet.show(
      context: context,
      product: product,
      availableAddons: availableAddons,
      maxProductQty: maxProductQty,
      addonRemainingStocks: addonRemainingStocks,
      onConfirm: (selectedAddons, qty) {
        cartCubit.addProductWithAddons(
          product,
          selectedAddons,
          qty: qty,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isExpanded = screenWidth >= AppSizes.expandedBreakpoint;
        final isMedium = screenWidth >= AppSizes.compactBreakpoint && !isExpanded;

        final int crossAxisCount;
        if (isExpanded) {
          crossAxisCount = 4;
        } else if (isMedium) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 2;
        }

        final horizontalPadding = isExpanded
            ? AppSpacing.gutterExpanded
            : AppSpacing.gutterCompact;

        final catalogArea = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Search Bar
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                AppSpacing.md,
                horizontalPadding,
                AppSpacing.xs,
              ),
              child: AppGlass(
                borderRadius: AppRadius.borderRadiusMd,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppStrings.searchProductHint,
                    hintStyle: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceMuted,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear_rounded,
                              size: 18,
                            ),
                            tooltip: AppStrings.close,
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                              context.read<ProductCubit>().search('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {});
                    context.read<ProductCubit>().search(val);
                  },
                ),
              ),
            ),

            // 2. Category Chips Row (Horizontal Scroll)
            _buildCategoryChipsRow(horizontalPadding),

            // 3. Inline Stock / Cart Error Banner
            BlocBuilder<CartCubit, CartState>(
              builder: (context, cartState) {
                if (!cartState.hasError) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    AppSpacing.xs,
                    horizontalPadding,
                    AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InlineError(
                          message: cartState.errorMessage!,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16),
                        color: AppColors.error,
                        tooltip: AppStrings.close,
                        onPressed: () =>
                            context.read<CartCubit>().clearError(),
                      ),
                    ],
                  ),
                );
              },
            ),

            // 4. Products Grid
            Expanded(
              child: BlocBuilder<ProductCubit, ProductState>(
                builder: (context, productState) {
                  if (productState.status == ProductStatus.loading &&
                      productState.products.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  // Filter out soft-deleted products
                  final activeProducts = productState.products
                      .where((p) => !p.isDeleted)
                      .toList();

                  if (activeProducts.isEmpty) {
                    final hasFilter =
                        productState.searchQuery.trim().isNotEmpty ||
                            productState.selectedCategoryId != null;
                    if (hasFilter) {
                      return const Center(
                        child: EmptyState(
                          title: AppStrings.noProductFoundTitle,
                          message: AppStrings.noProductFoundSubtitle,
                          icon: Icons.search_off_rounded,
                        ),
                      );
                    }
                    return const Center(
                      child: EmptyState(
                        title: AppStrings.emptyProductTitle,
                        message: AppStrings.emptyProductSubtitle,
                        icon: Icons.inventory_2_outlined,
                      ),
                    );
                  }

                  return BlocBuilder<CartCubit, CartState>(
                    builder: (context, cartState) {
                      return GridView.builder(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          AppSpacing.sm,
                          horizontalPadding,
                          isExpanded
                              ? AppSpacing.md
                              : (AppSizes.navBarHeight + AppSpacing.md),
                        ),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: AppSpacing.gutterCompact,
                          mainAxisSpacing: AppSpacing.gutterCompact,
                          childAspectRatio: isExpanded ? 0.65 : 0.72,
                        ),
                        itemCount: activeProducts.length,
                        itemBuilder: (context, index) {
                          final product = activeProducts[index];
                          final unitsInCart = cartState.items
                              .where((line) => line.productId == product.id)
                              .fold<int>(0, (sum, line) => sum + line.qty);

                          return CashierProductCard(
                            key: Key('cashier_product_card_${product.id}'),
                            product: product,
                            unitsInCart: unitsInCart,
                            photoStorage: widget.photoStorage,
                            onTap: () => _onProductTapped(
                              context,
                              product,
                              unitsInCart,
                              cartState,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );

        if (isExpanded) {
          // Expanded (>= 840dp): Side-by-side with Fixed Cart Panel on the right
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Row(
              children: [
                Expanded(child: catalogArea),
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: AppColors.borderHairline,
                ),
                SizedBox(
                  width: AppSizes.cartPanelWidth,
                  child: const AppGlass(
                    isStrong: true,
                    borderRadius: BorderRadius.zero,
                    child: CashierCartView(isSheet: false),
                  ),
                ),
              ],
            ),
          );
        }

        // Compact & Medium: Catalog + Sticky Summary Bar
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              catalogArea,
              const Positioned(
                left: 0,
                right: 0,
                bottom: AppSpacing.xs,
                child: CashierSummaryBar(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChipsRow(double horizontalPadding) {
    return BlocBuilder<ProductCubit, ProductState>(
      buildWhen: (prev, curr) =>
          prev.selectedCategoryId != curr.selectedCategoryId,
      builder: (context, productState) {
        final categories =
            context.watch<CategoryCubit?>()?.state.categories ?? [];

        return Container(
          height: AppSizes.chipHeight + AppSpacing.md,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: AppSpacing.xs,
          ),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final isSelected = isAll
                  ? productState.selectedCategoryId == null
                  : productState.selectedCategoryId == categories[index - 1].id;
              final label = isAll
                  ? AppStrings.allCategories
                  : categories[index - 1].name;

              return InkWell(
                key: Key(isAll
                    ? 'category_chip_all'
                    : 'category_chip_${categories[index - 1].id}'),
                borderRadius: AppRadius.borderRadiusFull,
                onTap: () {
                  final catId = isAll ? null : categories[index - 1].id;
                  context.read<ProductCubit>().filterByCategory(catId);
                },
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: AppSizes.touchMin,
                    minHeight: AppSizes.chipHeight,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primarySoft
                        : Colors.transparent,
                    borderRadius: AppRadius.borderRadiusFull,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderHairline,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    label,
                    style: AppTypography.caption.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
