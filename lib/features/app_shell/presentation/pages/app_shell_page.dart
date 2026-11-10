import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_button.dart';
import '../../../../core/theme/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_glass.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../../features/auth/presentation/cubit/auth_state.dart';
import '../../../../features/category/presentation/cubit/category_cubit.dart';
import '../../../../features/addon/presentation/cubit/addon_cubit.dart';
import '../../../../features/cashier/presentation/cubit/cart_cubit.dart';
import '../../../../features/cashier/presentation/pages/cashier_view.dart';
import '../../../../features/product/presentation/cubit/product_cubit.dart';
import '../../../../features/product/presentation/pages/product_shell_page.dart';
import '../../../../features/store_profile/presentation/cubit/store_profile_cubit.dart';
import '../../../../features/store_profile/presentation/pages/settings_page.dart';
import '../../../../features/transaction/presentation/cubit/report_cubit.dart';
import '../../../../features/transaction/presentation/pages/report_page.dart';
import '../widgets/floating_glass_bottom_bar.dart';

/// AppShell hosts the primary 4 destinations after authentication:
/// 1. Kasir (Cashier) - default initial tab
/// 2. Produk (Product)
/// 3. Laporan (Report)
/// 4. Pengaturan (Settings)
///
/// Responsive behavior via LayoutBuilder:
/// - Compact (< 600dp) & Medium (600-839dp): Floating glass bottom bar
/// - Expanded (>= 840dp): Side navigation rail on the left
///
/// Uses IndexedStack to guarantee tab states are preserved without rebuilding.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.initialIndex = 0,
    this.storeProfileCubit,
    this.productCubit,
    this.categoryCubit,
    this.addonCubit,
    this.cartCubit,
    this.reportCubit,
    this.cashierChild,
    this.reportChild,
  });

  static const String routeName = AppRoutes.home;

  final int initialIndex;
  final StoreProfileCubit? storeProfileCubit;
  final ProductCubit? productCubit;
  final CategoryCubit? categoryCubit;
  final AddonCubit? addonCubit;
  final CartCubit? cartCubit;
  final ReportCubit? reportCubit;
  final Widget? cashierChild;
  final Widget? reportChild;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;

  static const List<AppShellDestinationItem> _destinations = [
    AppShellDestinationItem(
      label: AppStrings.navCashier,
      icon: Icons.point_of_sale_outlined,
      selectedIcon: Icons.point_of_sale_rounded,
    ),
    AppShellDestinationItem(
      label: AppStrings.navProduct,
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2_rounded,
    ),
    AppShellDestinationItem(
      label: AppStrings.navReport,
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart_rounded,
    ),
    AppShellDestinationItem(
      label: AppStrings.navSettings,
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
    ),
  ];

  List<Widget> _buildPages() => [
    Builder(
      builder: (ctx) {
        try {
          ctx.read<CartCubit>();
          ctx.read<ProductCubit>();
          return const CashierView();
        } catch (_) {
          return widget.cashierChild ?? const CashierPlaceholderView();
        }
      },
    ),
    const ProductShellPage(),
    Builder(
      builder: (ctx) {
        try {
          ctx.read<ReportCubit>();
          return widget.reportChild ??
              ReportPage(isActive: _currentIndex == 2);
        } catch (_) {
          return widget.reportChild ?? const ReportPlaceholderView();
        }
      },
    ),
    SettingsPage(storeProfileCubit: widget.storeProfileCubit),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onDestinationSelected(int index, [BuildContext? innerContext]) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
    final effectiveContext = innerContext ?? context;
    if (index == 1) {
      try {
        effectiveContext.read<ProductCubit>().loadProducts();
        effectiveContext.read<CategoryCubit>().loadCategories();
        effectiveContext.read<AddonCubit>().loadAddons();
      } catch (_) {}
    } else if (index == 2) {
      try {
        effectiveContext.read<ReportCubit>().loadReport();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isExpanded = constraints.maxWidth >= AppSizes.expandedBreakpoint;
          final pages = _buildPages();

          return Scaffold(
            backgroundColor: AppColors.background,
            body: isExpanded
                ? Row(
                    children: [
                      _buildNavigationRail(context),
                      const VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: AppColors.borderHairline,
                      ),
                      Expanded(
                        child: IndexedStack(
                          index: _currentIndex,
                          children: pages,
                        ),
                      ),
                    ],
                  )
                : IndexedStack(
                    index: _currentIndex,
                    children: pages,
                  ),
            bottomNavigationBar: isExpanded
                ? null
                : SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.gutterCompact,
                        right: AppSpacing.gutterCompact,
                        bottom: AppSpacing.md,
                      ),
                      child: FloatingGlassBottomBar(
                        currentIndex: _currentIndex,
                        destinations: _destinations,
                        onTap: (index) => _onDestinationSelected(index, context),
                      ),
                    ),
                  ),
          );
        },
      ),
    );

    final providers = <BlocProvider>[];
    if (widget.productCubit != null) {
      providers.add(
        BlocProvider<ProductCubit>.value(
          value: widget.productCubit!..loadProducts(),
        ),
      );
    } else if (getIt.isRegistered<ProductCubit>()) {
      providers.add(
        BlocProvider<ProductCubit>(
          create: (_) => getIt<ProductCubit>()..loadProducts(),
        ),
      );
    }

    if (widget.categoryCubit != null) {
      providers.add(
        BlocProvider<CategoryCubit>.value(
          value: widget.categoryCubit!..loadCategories(),
        ),
      );
    } else if (getIt.isRegistered<CategoryCubit>()) {
      providers.add(
        BlocProvider<CategoryCubit>(
          create: (_) => getIt<CategoryCubit>()..loadCategories(),
        ),
      );
    }

    if (widget.addonCubit != null) {
      providers.add(
        BlocProvider<AddonCubit>.value(
          value: widget.addonCubit!..loadAddons(),
        ),
      );
    } else if (getIt.isRegistered<AddonCubit>()) {
      providers.add(
        BlocProvider<AddonCubit>(
          create: (_) => getIt<AddonCubit>()..loadAddons(),
        ),
      );
    }

    if (widget.cartCubit != null) {
      providers.add(
        BlocProvider<CartCubit>.value(
          value: widget.cartCubit!,
        ),
      );
    } else if (getIt.isRegistered<CartCubit>()) {
      providers.add(
        BlocProvider<CartCubit>(
          create: (_) => getIt<CartCubit>(),
        ),
      );
    }

    if (widget.reportCubit != null) {
      providers.add(
        BlocProvider<ReportCubit>.value(
          value: widget.reportCubit!..loadReport(),
        ),
      );
    } else if (getIt.isRegistered<ReportCubit>()) {
      providers.add(
        BlocProvider<ReportCubit>(
          create: (_) => getIt<ReportCubit>()..loadReport(),
        ),
      );
    }

    if (providers.isNotEmpty) {
      return MultiBlocProvider(
        providers: providers,
        child: content,
      );
    }

    return content;
  }

  Widget _buildNavigationRail(BuildContext context) {
    return AppGlass(
      isStrong: true,
      borderRadius: BorderRadius.zero,
      child: NavigationRail(
        backgroundColor: Colors.transparent,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            _onDestinationSelected(index, context),
        labelType: NavigationRailLabelType.all,
        minWidth: 84,
        useIndicator: true,
        indicatorColor: AppColors.primarySoft,
        selectedIconTheme: const IconThemeData(
          color: AppColors.primary,
          size: 24,
        ),
        unselectedIconTheme: const IconThemeData(
          color: AppColors.onSurfaceVariant,
          size: 24,
        ),
        selectedLabelTextStyle: AppTypography.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: AppTypography.caption.copyWith(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: const Icon(
              Icons.store_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ),
        destinations: _destinations.map((d) {
          return NavigationRailDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: Text(d.label),
          );
        }).toList(),
      ),
    );
  }
}

/// Shared app bar for placeholder destinations.
class _PlaceholderAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _PlaceholderAppBar({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.navBarHeight);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: AppGlass(
        isStrong: true,
        borderRadius: BorderRadius.zero,
        child: SafeArea(
          bottom: false,
          child: Container(
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
                  child: Icon(
                    icon,
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
                        title,
                        style: AppTypography.title.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subtitle,
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
        ),
      ),
    );
  }
}

/// Tab 1: Kasir Placeholder (Primary home destination).
/// Contains a stateful counter to verify IndexedStack preserves child state across tab navigation.
class CashierPlaceholderView extends StatefulWidget {
  const CashierPlaceholderView({super.key});

  @override
  State<CashierPlaceholderView> createState() => _CashierPlaceholderViewState();
}

class _CashierPlaceholderViewState extends State<CashierPlaceholderView> {
  int _orderCounter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const _PlaceholderAppBar(
        title: AppStrings.navCashier,
        subtitle: AppStrings.cashierPlaceholderSubtitle,
        icon: Icons.point_of_sale_rounded,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.gutterCompact),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: AppRadius.borderRadiusMd,
                            ),
                            child: const Icon(
                              Icons.point_of_sale_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.navCashier,
                                  style: AppTypography.headlineMd.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  AppStrings.cashierPlaceholderSubtitle,
                                  style: AppTypography.bodySm.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Divider(
                        color: AppColors.borderHairline,
                        height: 1,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Status Transaksi',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Siap Melayani',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Simulasi Antrean',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '$_orderCounter pesanan',
                            key: const Key('cashier_counter_text'),
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                              fontFeatures: AppTypography.tabularFigures,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(
                        text: 'Tambah Antrean',
                        variant: AppButtonVariant.secondary,
                        onPressed: () {
                          setState(() {
                            _orderCounter++;
                          });
                        },
                      ),
                    ],
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

/// Tab 2: Produk Placeholder.
class ProductPlaceholderView extends StatelessWidget {
  const ProductPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const _PlaceholderAppBar(
        title: AppStrings.navProduct,
        subtitle: AppStrings.productPlaceholderSubtitle,
        icon: Icons.inventory_2_rounded,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.gutterCompact),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    AppStrings.navProduct,
                    style: AppTypography.headlineMd,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    AppStrings.productPlaceholderSubtitle,
                    style: AppTypography.bodyMd,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tab 3: Laporan Placeholder.
class ReportPlaceholderView extends StatelessWidget {
  const ReportPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const _PlaceholderAppBar(
        title: AppStrings.navReport,
        subtitle: AppStrings.reportPlaceholderSubtitle,
        icon: Icons.bar_chart_rounded,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.gutterCompact),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    AppStrings.navReport,
                    style: AppTypography.headlineMd,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    AppStrings.reportPlaceholderSubtitle,
                    style: AppTypography.bodyMd,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


