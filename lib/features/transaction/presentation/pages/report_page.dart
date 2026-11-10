import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_button.dart';
import '../../../../core/theme/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_glass.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/utils/format_rupiah.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/transaction.dart';
import '../cubit/report_cubit.dart';
import '../cubit/report_state.dart';
import 'receipt_page.dart';

/// Report & Transaction History screen.
///
/// Adheres strictly to DESIGN.md:
/// - Light, clean, frosted soft-glass design.
/// - Stat cards for total revenue and successful transaction count.
/// - Transaction history list sorted newest first.
/// - Solid white AppCards for list rows (strictly NO BackdropFilter inside scrolling lists).
/// - Tabular figures on all numbers, dates, invoices, and prices.
/// - Right-aligned money amounts.
/// - Tapping an item opens ReceiptPage built from snapshot data.
class ReportPage extends StatefulWidget {
  final bool isActive;

  const ReportPage({
    super.key,
    this.isActive = true,
  });

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  @override
  void initState() {
    super.initState();
    // Load report data on initial mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ReportCubit>().loadReport();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ReportPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      context.read<ReportCubit>().loadReport();
    }
  }

  void _openReceipt(BuildContext context, Transaction transaction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReceiptPage(transaction: transaction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: BlocBuilder<ReportCubit, ReportState>(
                builder: (context, state) {
                  if (state.status == ReportStatus.loading &&
                      state.transactions.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (state.status == ReportStatus.failure &&
                      state.transactions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              state.errorMessage ?? AppStrings.loadReportFailed,
                              style: AppTypography.bodyMd,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppButton(
                              text: AppStrings.retry,
                              variant: AppButtonVariant.primary,
                              onPressed: () =>
                                  context.read<ReportCubit>().loadReport(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.surfaceCard,
                    onRefresh: () => context.read<ReportCubit>().loadReport(),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 840),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.gutterCompact,
                                  vertical: AppSpacing.md,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _buildStatCards(state),
                                    const SizedBox(height: AppSpacing.xl),
                                    _buildHistorySectionHeader(state),
                                    const SizedBox(height: AppSpacing.md),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (state.transactions.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 480),
                                child: const EmptyState(
                                  title: AppStrings.emptyTransactionsTitle,
                                  message: AppStrings.emptyTransactionsSubtitle,
                                  icon: Icons.receipt_long_outlined,
                                ),
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.only(
                              left: AppSpacing.gutterCompact,
                              right: AppSpacing.gutterCompact,
                              bottom: AppSizes.navBarHeight + AppSpacing.xl,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 840),
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: state.transactions.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: AppSpacing.sm),
                                    itemBuilder: (context, index) {
                                      final tx = state.transactions[index];
                                      return _buildTransactionCard(context, tx);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AppGlass(
      isStrong: true,
      borderRadius: BorderRadius.zero,
      child: Container(
        height: AppSizes.navBarHeight,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.gutterCompact,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    AppStrings.reportTitle,
                    style: AppTypography.title,
                  ),
                  Text(
                    AppStrings.reportSubtitle,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              color: AppColors.onSurfaceVariant,
              tooltip: AppStrings.refreshReport,
              onPressed: () => context.read<ReportCubit>().loadReport(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(ReportState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 420;

        final revenueCard = _buildSingleStatCard(
          title: AppStrings.totalRevenueLabel,
          value: formatRupiah(state.totalRevenue),
          icon: Icons.payments_rounded,
          isPrimaryValue: true,
        );

        final countCard = _buildSingleStatCard(
          title: AppStrings.successfulTransactionsLabel,
          value: '${state.transactionCount}',
          icon: Icons.receipt_long_rounded,
          isPrimaryValue: false,
        );

        if (isNarrow) {
          return Column(
            children: [
              revenueCard,
              const SizedBox(height: AppSpacing.sm),
              countCard,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: revenueCard),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: countCard),
          ],
        );
      },
    );
  }

  Widget _buildSingleStatCard({
    required String title,
    required String value,
    required IconData icon,
    required bool isPrimaryValue,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTypography.headlineMd.copyWith(
              color: isPrimaryValue ? AppColors.primary : AppColors.onSurface,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySectionHeader(ReportState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          AppStrings.transactionHistoryTitle,
          style: AppTypography.headlineMd,
        ),
        if (state.transactions.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: AppRadius.borderRadiusFull,
            ),
            child: Text(
              '${state.transactions.length} ${AppStrings.transactionCountUnit}',
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTransactionCard(BuildContext context, Transaction tx) {
    final itemCount = tx.items.fold<int>(0, (sum, item) => sum + item.qty);

    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: AppRadius.borderRadiusLg,
        onTap: () => _openReceipt(context, tx),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Icon marker
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                child: const Icon(
                  Icons.receipt_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Invoice & Date & Cashier
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.invoiceNo,
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: AppColors.onSurfaceMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formatDateTime(tx.createdAt),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.onSurfaceMuted,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '• $itemCount item',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.onSurfaceMuted,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Right-aligned Price & Chevron
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatRupiah(tx.total),
                    textAlign: TextAlign.right,
                    style: AppTypography.price.copyWith(
                      color: AppColors.primary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.onSurfaceMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
