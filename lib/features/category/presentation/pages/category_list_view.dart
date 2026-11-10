import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/theme/app_button.dart';
import '../../../../core/theme/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/category.dart';
import '../cubit/category_cubit.dart';
import '../cubit/category_state.dart';
import '../widgets/category_delete_dialog.dart';
import '../widgets/category_form_dialog.dart';

class CategoryListView extends StatelessWidget {
  const CategoryListView({super.key});

  void _openAddCategory(BuildContext context) {
    CategoryFormDialog.show(
      context,
      onSave: (name) async {
        final cubit = context.read<CategoryCubit>();
        await cubit.addCategory(name);
        if (cubit.state.status == CategoryStatus.failure) {
          throw AppException(
            cubit.state.errorMessage ?? AppStrings.categoryNameDuplicate,
          );
        }
      },
    );
  }

  void _openEditCategory(BuildContext context, Category category) {
    CategoryFormDialog.show(
      context,
      category: category,
      onSave: (name) async {
        final cubit = context.read<CategoryCubit>();
        await cubit.updateCategory(category.id, name);
        if (cubit.state.status == CategoryStatus.failure) {
          throw AppException(
            cubit.state.errorMessage ?? AppStrings.categoryNameDuplicate,
          );
        }
      },
    );
  }

  void _openDeleteCategory(BuildContext context, Category category) {
    CategoryDeleteDialog.show(
      context,
      category: category,
      onConfirmDelete: () async {
        final cubit = context.read<CategoryCubit>();
        await cubit.deleteCategory(category.id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryCubit, CategoryState>(
      listener: (context, state) {
        if (state.status == CategoryStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage!,
                style: AppTypography.bodySm.copyWith(color: AppColors.onPrimary),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.borderRadiusMd,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.gutterCompact,
            vertical: AppSpacing.md,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Action header
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.categoryListTitle,
                                style: AppTypography.title.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppStrings.categoryListSubtitle,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        AppButton(
                          text: AppStrings.addCategory,
                          variant: AppButtonVariant.primary,
                          leadingIcon: const Icon(
                            Icons.add_rounded,
                            size: 20,
                            color: AppColors.onPrimary,
                          ),
                          onPressed: () => _openAddCategory(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // State view
                  if (state.status == CategoryStatus.loading &&
                      state.categories.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else if (state.categories.isEmpty)
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: EmptyState(
                        title: AppStrings.emptyCategoryTitle,
                        message: AppStrings.emptyCategorySubtitle,
                        icon: Icons.category_outlined,
                        action: AppButton(
                          text: AppStrings.addCategory,
                          variant: AppButtonVariant.primary,
                          onPressed: () => _openAddCategory(context),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.categories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final category = state.categories[index];
                        return AppCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: AppRadius.borderRadiusSm,
                                ),
                                child: const Icon(
                                  Icons.folder_outlined,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.name,
                                      style: AppTypography.title.copyWith(
                                        color: AppColors.onSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${category.productCount} ${AppStrings.productCountSuffix}',
                                      key: Key(
                                        'category_count_${category.id}',
                                      ),
                                      style: AppTypography.bodySm.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                        fontFeatures:
                                            AppTypography.tabularFigures,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minWidth: 48,
                                  minHeight: 48,
                                ),
                                child: IconButton(
                                  key: Key('btn_edit_${category.id}'),
                                  tooltip: AppStrings.edit,
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  splashRadius: 24,
                                  onPressed: () =>
                                      _openEditCategory(context, category),
                                ),
                              ),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minWidth: 48,
                                  minHeight: 48,
                                ),
                                child: IconButton(
                                  key: Key('btn_delete_${category.id}'),
                                  tooltip: AppStrings.delete,
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 20,
                                    color: AppColors.error,
                                  ),
                                  splashRadius: 24,
                                  onPressed: () =>
                                      _openDeleteCategory(context, category),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

