import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
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
import '../../../../features/product/presentation/pages/product_shell_page.dart';
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
  const AppShell({super.key, this.initialIndex = 0});

  static const String routeName = AppRoutes.home;

  final int initialIndex;

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

  late final List<Widget> _pages = [
    const CashierPlaceholderView(),
    const ProductShellPage(),
    const ReportPlaceholderView(),
    const SettingsPlaceholderView(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onDestinationSelected(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
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

          return Scaffold(
            backgroundColor: AppColors.background,
            body: isExpanded
                ? Row(
                    children: [
                      _buildNavigationRail(),
                      const VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: AppColors.borderHairline,
                      ),
                      Expanded(
                        child: IndexedStack(
                          index: _currentIndex,
                          children: _pages,
                        ),
                      ),
                    ],
                  )
                : IndexedStack(
                    index: _currentIndex,
                    children: _pages,
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
                        onTap: _onDestinationSelected,
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildNavigationRail() {
    return AppGlass(
      isStrong: true,
      borderRadius: BorderRadius.zero,
      child: NavigationRail(
        backgroundColor: Colors.transparent,
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
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

/// Tab 4: Pengaturan Placeholder.
/// Provides user session details and clean confirmation dialog for logout.
class SettingsPlaceholderView extends StatelessWidget {
  const SettingsPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const _PlaceholderAppBar(
        title: AppStrings.navSettings,
        subtitle: AppStrings.settingsPlaceholderSubtitle,
        icon: Icons.settings_rounded,
      ),
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final user = state.user;
            final dateFormatted = DateFormat('dd MMM yyyy, HH:mm').format(
              DateTime.now(),
            );

            return SingleChildScrollView(
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
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: AppColors.primarySoft,
                                  child: Text(
                                    (user?.name.isNotEmpty ?? false)
                                        ? user!.name[0].toUpperCase()
                                        : 'K',
                                    style: AppTypography.headlineMd.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user?.name ?? 'Kasir Vonte',
                                        style: AppTypography.title.copyWith(
                                          color: AppColors.onSurface,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '@${user?.username ?? "kasir"}',
                                        style: AppTypography.bodySm.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: AppColors.successSoft,
                                    borderRadius: AppRadius.borderRadiusFull,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.success,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        AppStrings.activeSessionTitle,
                                        style: AppTypography.caption.copyWith(
                                          color: AppColors.success,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            const Divider(
                              color: AppColors.borderHairline,
                              height: 1,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Waktu Sesi Dimulai',
                                    style: AppTypography.bodySm.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  dateFormatted,
                                  style: AppTypography.bodySm.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w600,
                                    fontFeatures: AppTypography.tabularFigures,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'ID Pengguna',
                                    style: AppTypography.bodySm.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  '#${user?.id ?? 0}',
                                  style: AppTypography.bodySm.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w600,
                                    fontFeatures: AppTypography.tabularFigures,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        text: AppStrings.logout,
                        variant: AppButtonVariant.destructive,
                        leadingIcon: const Icon(
                          Icons.logout_rounded,
                          size: 20,
                          color: AppColors.error,
                        ),
                        onPressed: () => _confirmLogout(context),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusXl,
          ),
          backgroundColor: AppColors.surfaceCard,
          title: Text(
            'Konfirmasi Keluar',
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin mengakhiri sesi kasir ini?',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                AppStrings.cancel,
                style: AppTypography.label.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            AppButton(
              text: AppStrings.logout,
              variant: AppButtonVariant.destructive,
              isSolidDestructive: true,
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthCubit>().logout();
              },
            ),
          ],
        );
      },
    );
  }
}
