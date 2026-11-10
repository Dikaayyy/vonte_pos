import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_glass.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../category/presentation/cubit/category_cubit.dart';
import '../../../category/presentation/pages/category_list_view.dart';
import '../../../addon/presentation/cubit/addon_cubit.dart';
import '../../../addon/presentation/pages/addon_list_view.dart';
import '../cubit/product_cubit.dart';
import 'product_list_view.dart';

class ProductShellPage extends StatefulWidget {
  final int initialSubIndex;
  final ProductCubit? productCubit;
  final CategoryCubit? categoryCubit;
  final AddonCubit? addonCubit;

  const ProductShellPage({
    super.key,
    this.initialSubIndex = 0,
    this.productCubit,
    this.categoryCubit,
    this.addonCubit,
  });

  @override
  State<ProductShellPage> createState() => _ProductShellPageState();
}

class _ProductShellPageState extends State<ProductShellPage> {
  late int _selectedSegment;

  static const List<String> _segments = [
    AppStrings.productTabLabel,
    AppStrings.categoryTabLabel,
    AppStrings.addonTabLabel,
  ];

  @override
  void initState() {
    super.initState();
    _selectedSegment = widget.initialSubIndex;
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(AppSizes.navBarHeight + 56),
          child: AppGlass(
            isStrong: true,
            borderRadius: BorderRadius.zero,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: AppSizes.navBarHeight,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.gutterCompact,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: AppRadius.borderRadiusSm,
                          ),
                          child: const Icon(
                            Icons.inventory_2_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.navProduct,
                                style: AppTypography.title.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                AppStrings.productPlaceholderSubtitle,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.gutterCompact,
                      right: AppSpacing.gutterCompact,
                      bottom: AppSpacing.sm,
                    ),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: AppRadius.borderRadiusFull,
                        border: Border.all(
                          color: AppColors.borderHairline,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: List.generate(_segments.length, (index) {
                          final isSelected = _selectedSegment == index;
                          return Expanded(
                            child: InkWell(
                              key: Key('segment_$index'),
                              borderRadius: AppRadius.borderRadiusFull,
                              onTap: () {
                                setState(() {
                                  _selectedSegment = index;
                                });
                              },
                              child: Container(
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primarySoft
                                      : Colors.transparent,
                                  borderRadius: AppRadius.borderRadiusFull,
                                  border: isSelected
                                      ? Border.all(
                                          color: AppColors.primary,
                                          width: 1,
                                        )
                                      : null,
                                ),
                                child: Text(
                                  _segments[index],
                                  style: AppTypography.label.copyWith(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.onSurfaceVariant,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: IndexedStack(
          index: _selectedSegment,
          children: [
            Builder(
              builder: (ctx) {
                try {
                  ctx.read<ProductCubit>();
                  return const ProductListView();
                } catch (_) {
                  return _buildPlaceholder(
                    title: AppStrings.productTabLabel,
                    subtitle: AppStrings.productCatalogPlaceholder,
                    icon: Icons.inventory_2_outlined,
                  );
                }
              },
            ),
            Builder(
              builder: (ctx) {
                try {
                  ctx.read<CategoryCubit>();
                  return const CategoryListView();
                } catch (_) {
                  return _buildPlaceholder(
                    title: AppStrings.categoryTabLabel,
                    subtitle: AppStrings.categoryListSubtitle,
                    icon: Icons.category_rounded,
                  );
                }
              },
            ),
            Builder(
              builder: (ctx) {
                try {
                  ctx.read<AddonCubit>();
                  return const AddonListView();
                } catch (_) {
                  return _buildPlaceholder(
                    title: AppStrings.addonTabLabel,
                    subtitle: AppStrings.addonCatalogPlaceholder,
                    icon: Icons.add_circle_outline_rounded,
                  );
                }
              },
            ),
          ],
        ),
      );

    final providers = <BlocProvider>[];
    if (widget.productCubit != null) {
      providers.add(
        BlocProvider<ProductCubit>.value(
          value: widget.productCubit!..loadProducts(),
        ),
      );
    } else {
      try {
        context.read<ProductCubit>();
      } catch (_) {
        if (getIt.isRegistered<ProductCubit>()) {
          providers.add(
            BlocProvider<ProductCubit>(
              create: (context) => getIt<ProductCubit>()..loadProducts(),
            ),
          );
        }
      }
    }

    if (widget.categoryCubit != null) {
      providers.add(
        BlocProvider<CategoryCubit>.value(
          value: widget.categoryCubit!..loadCategories(),
        ),
      );
    } else {
      try {
        context.read<CategoryCubit>();
      } catch (_) {
        if (getIt.isRegistered<CategoryCubit>()) {
          providers.add(
            BlocProvider<CategoryCubit>(
              create: (context) => getIt<CategoryCubit>()..loadCategories(),
            ),
          );
        }
      }
    }

    if (widget.addonCubit != null) {
      providers.add(
        BlocProvider<AddonCubit>.value(
          value: widget.addonCubit!..loadAddons(),
        ),
      );
    } else {
      try {
        context.read<AddonCubit>();
      } catch (_) {
        if (getIt.isRegistered<AddonCubit>()) {
          providers.add(
            BlocProvider<AddonCubit>(
              create: (context) => getIt<AddonCubit>()..loadAddons(),
            ),
          );
        }
      }
    }

    if (providers.isNotEmpty) {
      return MultiBlocProvider(
        providers: providers,
        child: content,
      );
    }

    return content;
  }

  Widget _buildPlaceholder({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.gutterCompact),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: AppRadius.borderRadiusSm,
                      ),
                      child: Icon(icon, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      title,
                      style: AppTypography.headlineMd.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  subtitle,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

