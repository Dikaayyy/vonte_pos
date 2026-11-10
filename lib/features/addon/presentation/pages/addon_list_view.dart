import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/theme/app_button.dart';
import '../../../../core/theme/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/format_rupiah.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/stock_badge.dart';
import '../../domain/entities/addon.dart';
import '../cubit/addon_cubit.dart';
import '../cubit/addon_state.dart';
import '../widgets/addon_delete_dialog.dart';
import '../widgets/addon_form_dialog.dart';

class AddonListView extends StatelessWidget {
  const AddonListView({super.key});

  void _openAddAddon(BuildContext context) {
    AddonFormDialog.show(
      context,
      onSave: ({required name, required price, required stock}) async {
        final cubit = context.read<AddonCubit>();
        await cubit.addAddon(name: name, price: price, stock: stock);
        if (cubit.state.status == AddonStatus.failure) {
          throw AppException(
            cubit.state.errorMessage ?? 'Gagal menambahkan add-on.',
          );
        }
      },
    );
  }

  void _openEditAddon(BuildContext context, Addon addon) {
    AddonFormDialog.show(
      context,
      addon: addon,
      onSave: ({required name, required price, required stock}) async {
        final cubit = context.read<AddonCubit>();
        await cubit.updateAddon(
          id: addon.id,
          name: name,
          price: price,
          stock: stock,
        );
        if (cubit.state.status == AddonStatus.failure) {
          throw AppException(
            cubit.state.errorMessage ?? 'Gagal memperbarui add-on.',
          );
        }
      },
    );
  }

  void _openDeleteAddon(BuildContext context, Addon addon) {
    AddonDeleteDialog.show(
      context,
      addon: addon,
      onConfirmDelete: () async {
        final cubit = context.read<AddonCubit>();
        await cubit.deleteAddon(addon.id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddonCubit, AddonState>(
      listener: (context, state) {
        if (state.status == AddonStatus.failure && state.errorMessage != null) {
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
                  // Action header card
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
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
                            Icons.add_circle_outline_rounded,
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
                                AppStrings.addonListTitle,
                                style: AppTypography.title.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                AppStrings.addonListSubtitle,
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        AppButton(
                          text: AppStrings.addAddon,
                          variant: AppButtonVariant.primary,
                          leadingIcon: const Icon(
                            Icons.add_rounded,
                            size: 20,
                            color: AppColors.onPrimary,
                          ),
                          onPressed: () => _openAddAddon(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Add-on items or empty state
                  if (state.status == AddonStatus.loading && state.addons.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else if (state.addons.isEmpty)
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xl,
                        horizontal: AppSpacing.lg,
                      ),
                      child: EmptyState(
                        title: AppStrings.emptyAddonTitle,
                        message: AppStrings.emptyAddonSubtitle,
                        icon: Icons.add_circle_outline_rounded,
                        action: AppButton(
                          text: AppStrings.addAddon,
                          variant: AppButtonVariant.secondary,
                          leadingIcon: const Icon(
                            Icons.add_rounded,
                            size: 20,
                            color: AppColors.onSurface,
                          ),
                          onPressed: () => _openAddAddon(context),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.addons.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final addon = state.addons[index];
                        return _buildAddonItem(context, addon);
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

  Widget _buildAddonItem(BuildContext context, Addon addon) {
    return AppCard(
      key: Key('addon_item_${addon.id}'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
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
              Icons.extension_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  addon.name,
                  style: AppTypography.title.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Text(
                      addon.price == 0
                          ? AppStrings.freePriceLabel
                          : formatRupiah(addon.price),
                      style: AppTypography.price.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    if (addon.isOutOfStock || addon.isLowStock)
                      StockBadge(stock: addon.stock)
                    else
                      Text(
                        '${AppStrings.stockLabelPrefix} ${addon.stock}',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Edit button
          SizedBox(
            width: AppSizes.touchMin,
            height: AppSizes.touchMin,
            child: IconButton(
              key: Key('edit_addon_${addon.id}'),
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.onSurfaceVariant,
                size: 20,
              ),
              tooltip: AppStrings.editAddon,
              splashRadius: 22,
              onPressed: () => _openEditAddon(context, addon),
            ),
          ),
          // Delete button
          SizedBox(
            width: AppSizes.touchMin,
            height: AppSizes.touchMin,
            child: IconButton(
              key: Key('delete_addon_${addon.id}'),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 20,
              ),
              tooltip: AppStrings.deleteAddon,
              splashRadius: 22,
              onPressed: () => _openDeleteAddon(context, addon),
            ),
          ),
        ],
      ),
    );
  }
}
