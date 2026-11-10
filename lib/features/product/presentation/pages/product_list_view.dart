import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/inline_error.dart';
import '../../../category/presentation/cubit/category_cubit.dart';
import '../../data/services/photo_storage.dart';
import '../../domain/entities/product.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';
import '../widgets/product_card.dart';
import '../widgets/product_delete_dialog.dart';
import '../widgets/product_form_dialog.dart';

class ProductListView extends StatefulWidget {
  final PhotoStorage? photoStorage;

  const ProductListView({
    super.key,
    this.photoStorage,
  });

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
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

  void _openAddDialog(BuildContext context) {
    ProductFormDialog.show(
      context,
      photoStorage: widget.photoStorage,
      onSave: ({
        required String name,
        int? categoryId,
        required int price,
        required int stock,
        String? photoPath,
        List<int> addonIds = const [],
      }) async {
        await context.read<ProductCubit>().addProduct(
              name: name,
              categoryId: categoryId,
              price: price,
              stock: stock,
              photoPath: photoPath,
              addonIds: addonIds,
            );
      },
    );
  }

  void _openEditDialog(BuildContext context, Product product) {
    ProductFormDialog.show(
      context,
      product: product,
      photoStorage: widget.photoStorage,
      onSave: ({
        required String name,
        int? categoryId,
        required int price,
        required int stock,
        String? photoPath,
        List<int> addonIds = const [],
      }) async {
        await context.read<ProductCubit>().updateProduct(
              id: product.id,
              name: name,
              categoryId: categoryId,
              price: price,
              stock: stock,
              photoPath: photoPath,
              addonIds: addonIds,
            );
      },
    );
  }

  void _openDeleteDialog(BuildContext context, Product product) {
    ProductDeleteDialog.show(
      context: context,
      productName: product.name,
      onConfirm: () {
        context.read<ProductCubit>().deleteProduct(product.id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final int crossAxisCount;
        if (screenWidth >= 840) {
          crossAxisCount = 4;
        } else if (screenWidth >= 600) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 2;
        }

        final horizontalPadding = screenWidth >= 840
            ? AppSpacing.gutterExpanded
            : AppSpacing.gutterCompact;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header with Add Button
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  AppSpacing.md,
                  horizontalPadding,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.productListTitle,
                            style: AppTypography.headlineMd.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppStrings.productListSubtitle,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    AppButton(
                      text: AppStrings.addProduct,
                      variant: AppButtonVariant.primary,
                      leadingIcon: const Icon(Icons.add_rounded, size: 20),
                      onPressed: () => _openAddDialog(context),
                    ),
                  ],
                ),
              ),

              // 2. Search Field
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: AppSpacing.xs,
                ),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: AppRadius.borderRadiusMd,
                    border: Border.all(
                      color: AppColors.borderHairline,
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurface,
                    ),
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
                                color: AppColors.onSurfaceVariant,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                context.read<ProductCubit>().search('');
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {});
                      context.read<ProductCubit>().search(val);
                    },
                  ),
                ),
              ),

              // 3. Category Filter Chips (horizontal scroll)
              _buildCategoryChipsRow(horizontalPadding),

              // 4. Products Grid Area
              Expanded(
                child: BlocBuilder<ProductCubit, ProductState>(
                  builder: (context, state) {
                    if (state.status == ProductStatus.loading &&
                        state.products.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (state.status == ProductStatus.failure &&
                        state.products.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InlineError(
                              message: state.errorMessage ??
                                  'Terjadi kesalahan saat memuat produk.',
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppButton(
                              text: AppStrings.retry,
                              variant: AppButtonVariant.secondary,
                              onPressed: () => context
                                  .read<ProductCubit>()
                                  .loadProducts(),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state.products.isEmpty) {
                      final hasFilter = state.searchQuery.trim().isNotEmpty ||
                          state.selectedCategoryId != null;
                      if (hasFilter) {
                        return const Center(
                          child: EmptyState(
                            title: AppStrings.noProductFoundTitle,
                            message: AppStrings.noProductFoundSubtitle,
                            icon: Icons.search_off_rounded,
                          ),
                        );
                      }
                      return Center(
                        child: EmptyState(
                          title: AppStrings.emptyProductTitle,
                          message: AppStrings.emptyProductSubtitle,
                          icon: Icons.inventory_2_outlined,
                          action: AppButton(
                            text: AppStrings.addProduct,
                            variant: AppButtonVariant.primary,
                            leadingIcon:
                                const Icon(Icons.add_rounded, size: 20),
                            onPressed: () => _openAddDialog(context),
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: AppSpacing.md,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: AppSpacing.gutterCompact,
                        mainAxisSpacing: AppSpacing.gutterCompact,
                        childAspectRatio: 0.60,
                      ),
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        return ProductCard(
                          product: product,
                          photoStorage: widget.photoStorage,
                          onEdit: () => _openEditDialog(context, product),
                          onDelete: () => _openDeleteDialog(context, product),
                        );
                      },
                    );
                  },
                ),
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
                key: Key(isAll ? 'category_chip_all' : 'category_chip_${categories[index - 1].id}'),
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
