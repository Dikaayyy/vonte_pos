import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
import '../../../../core/utils/format_rupiah.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/dashed_divider.dart';
import '../../../../core/widgets/inline_error.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../store_profile/presentation/cubit/store_profile_cubit.dart';
import '../../../transaction/presentation/pages/receipt_page.dart';
import '../../domain/entities/cart_line.dart';
import '../../domain/entities/discount.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/checkout_cubit.dart';
import '../cubit/checkout_state.dart';

/// Checkout screen complying strictly with DESIGN.md:
/// - Summary block with accent glass: subtotal, discount, total.
/// - Segmented discount control (Rp | %) with live inline validation.
/// - Cash received numeric field with quick-cash chips ("Uang pas" + banknotes).
/// - Live change indicator ("Uang kurang" shortage warning or "Kembalian" success).
/// - "Bayar" button disabled until everything is valid.
/// - On success: clears the cart and displays the Receipt page.
class CheckoutPage extends StatefulWidget {
  final CheckoutCubit? checkoutCubit;
  final CartCubit? cartCubit;
  final List<CartLine>? initialLines;

  const CheckoutPage({
    super.key,
    this.checkoutCubit,
    this.cartCubit,
    this.initialLines,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late final CheckoutCubit _checkoutCubit;
  late final bool _isLocalCubit;
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _cashController = TextEditingController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.checkoutCubit != null) {
      _checkoutCubit = widget.checkoutCubit!;
      _isLocalCubit = false;
    } else if (getIt.isRegistered<CheckoutCubit>()) {
      _checkoutCubit = getIt<CheckoutCubit>();
      _isLocalCubit = true;
    } else {
      throw StateError('CheckoutCubit is not registered in getIt.');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initCubit();
      _initialized = true;
    }
  }

  void _initCubit() {
    // 1. Resolve Cart Lines
    CartCubit? cart = widget.cartCubit;
    if (cart == null) {
      final routeArg = ModalRoute.of(context)?.settings.arguments;
      if (routeArg is CartCubit) {
        cart = routeArg;
      } else {
        try {
          cart = context.read<CartCubit>();
        } catch (_) {}
      }
    }

    final lines = widget.initialLines ?? (cart?.state.lines ?? const []);

    // 2. Resolve Cashier Identity
    int cashierId = 1;
    String cashierName = 'Kasir';
    try {
      final authUser = context.read<AuthCubit>().state.user;
      if (authUser != null) {
        cashierId = authUser.id;
        cashierName = authUser.name;
      }
    } catch (_) {}

    // 3. Resolve Store Profile
    String? storeName;
    String? storeAddress;
    String? storePhone;
    try {
      final store = context.read<StoreProfileCubit>().state.profile;
      if (store != null) {
        storeName = store.name;
        storeAddress = store.address;
        storePhone = store.phone;
      }
    } catch (_) {}

    _checkoutCubit.init(
      lines: lines,
      cashierId: cashierId,
      cashierName: cashierName,
      storeName: storeName,
      storeAddress: storeAddress,
      storePhone: storePhone,
      initialDiscount: cart?.state.discount,
    );

    if (_checkoutCubit.state.discountValue > 0) {
      _discountController.text = _checkoutCubit.state.discountValue.toString();
    }
  }

  CartCubit? _resolveCartCubit() {
    if (widget.cartCubit != null) return widget.cartCubit;
    final routeArg = ModalRoute.of(context)?.settings.arguments;
    if (routeArg is CartCubit) return routeArg;
    try {
      return context.read<CartCubit>();
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _discountController.dispose();
    _cashController.dispose();
    if (_isLocalCubit) {
      _checkoutCubit.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CheckoutCubit>.value(
      value: _checkoutCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(AppSizes.navBarHeight),
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
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppColors.onSurface,
                      tooltip: AppStrings.cancel,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      AppStrings.checkoutTitle,
                      style: AppTypography.title.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: BlocConsumer<CheckoutCubit, CheckoutState>(
          listener: (context, state) {
            if (state.status == CheckoutStatus.success &&
                state.transaction != null) {
              // Rule: After success, clear cart and show receipt
              _resolveCartCubit()?.clearCart();

              String? customFooter;
              try {
                customFooter = context
                    .read<StoreProfileCubit>()
                    .state
                    .profile
                    ?.receiptFooter;
              } catch (_) {}

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ReceiptPage(
                    transaction: state.transaction!,
                    customFooter: customFooter,
                  ),
                ),
              );
            } else if (state.status == CheckoutStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.gutterCompact),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Summary Block (Accent Glass)
                      _buildSummaryBlock(state),
                      const SizedBox(height: AppSpacing.lg),

                      // 2. Discount Section (Segmented Rp | %)
                      _buildDiscountSection(state),
                      const SizedBox(height: AppSpacing.lg),

                      // 3. Cash Received & Quick Cash Section
                      _buildCashSection(state),
                      const SizedBox(height: AppSpacing.xl),

                      // 4. Failure Message Banner (if any)
                      if (state.status == CheckoutStatus.failure &&
                          state.errorMessage != null) ...[
                        InlineError(message: state.errorMessage!),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // 5. Pay Button
                      AppButton(
                        text: state.status == CheckoutStatus.processing
                            ? 'Memproses Pembayaran...'
                            : '${AppStrings.payButton} ${formatRupiah(state.total)}',
                        variant: AppButtonVariant.primary,
                        isLarge: true,
                        fullWidth: true,
                        isLoading: state.status == CheckoutStatus.processing,
                        onPressed: state.isValid
                            ? () => _checkoutCubit.submitPayment()
                            : null,
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

  Widget _buildSummaryBlock(CheckoutState state) {
    return AppGlass(
      isAccent: true,
      borderRadius: AppRadius.borderRadiusLg,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.subtotal,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                formatRupiah(state.subtotal),
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          if (state.discountAmount > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppStrings.discount} (${state.discountType == DiscountType.percent ? '${state.discountValue}%' : 'Rp'})',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.error,
                  ),
                ),
                Text(
                  '-${formatRupiah(state.discountAmount)}',
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          const DashedDivider(color: AppColors.borderHairline),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                AppStrings.totalBill,
                style: AppTypography.title.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                formatRupiah(state.total),
                style: AppTypography.totalDisplay.copyWith(
                  color: AppColors.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountSection(CheckoutState state) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.discountLabel,
                style: AppTypography.title.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              // Segmented control: Rp | %
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppRadius.borderRadiusMd,
                  border: Border.all(color: AppColors.borderHairline),
                ),
                padding: const EdgeInsets.all(2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSegmentButton(
                      label: AppStrings.discountTypeRp,
                      isSelected: state.discountType == DiscountType.fixed,
                      onTap: () {
                        _checkoutCubit.setDiscountType(DiscountType.fixed);
                      },
                    ),
                    _buildSegmentButton(
                      label: AppStrings.discountTypePercent,
                      isSelected: state.discountType == DiscountType.percent,
                      onTap: () {
                        _checkoutCubit.setDiscountType(DiscountType.percent);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: state.discountType == DiscountType.percent
                ? 'Persentase Diskon (%)'
                : 'Nominal Diskon (Rp)',
            hint: state.discountType == DiscountType.percent
                ? AppStrings.discountPercentHint
                : AppStrings.discountHint,
            controller: _discountController,
            keyboardType: TextInputType.number,
            errorText: state.discountError,
            onChanged: (val) {
              _checkoutCubit.setDiscountInput(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderRadiusSm,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySoft : Colors.transparent,
            borderRadius: AppRadius.borderRadiusSm,
          ),
          child: Text(
            label,
            style: AppTypography.label.copyWith(
              color:
                  isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCashSection(CheckoutState state) {
    final bool isShortage = state.cashReceived < state.total;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.cashReceivedLabel,
            style: AppTypography.title.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Quick Cash Chips: "Uang pas" + Sensible banknotes
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              // Exact Money Chip
              ActionChip(
                label: Text('${AppStrings.exactMoney} (${formatRupiah(state.total)})'),
                labelStyle: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: state.cashReceived == state.total && state.total > 0
                      ? AppColors.primary
                      : AppColors.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                backgroundColor:
                    state.cashReceived == state.total && state.total > 0
                        ? AppColors.primarySoft
                        : AppColors.background,
                side: BorderSide(
                  color:
                      state.cashReceived == state.total && state.total > 0
                          ? AppColors.primary
                          : AppColors.borderHairline,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.borderRadiusFull,
                ),
                onPressed: () {
                  _cashController.text = state.total.toString();
                  _checkoutCubit.selectQuickCash(state.total);
                },
              ),
              // Banknote Denomination Chips
              ...state.quickCashOptions
                  .where((opt) => opt > state.total)
                  .map((amount) {
                final isSelected = state.cashReceived == amount;
                return ActionChip(
                  label: Text(formatRupiah(amount)),
                  labelStyle: AppTypography.bodySm.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  backgroundColor: isSelected
                      ? AppColors.primarySoft
                      : AppColors.background,
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.borderHairline,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusFull,
                  ),
                  onPressed: () {
                    _cashController.text = amount.toString();
                    _checkoutCubit.selectQuickCash(amount);
                  },
                );
              }),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Cash Input Field
          AppTextField(
            label: 'Nominal Uang (Rp)',
            hint: AppStrings.cashReceivedHint,
            controller: _cashController,
            keyboardType: TextInputType.number,
            onChanged: (val) {
              _checkoutCubit.setCashReceivedInput(val);
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Live Change Indicator Box
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: isShortage ? AppColors.errorSoft : AppColors.successSoft,
              borderRadius: AppRadius.borderRadiusMd,
              border: Border.all(
                color: isShortage
                    ? AppColors.error.withValues(alpha: 0.3)
                    : AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isShortage
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline_rounded,
                  color: isShortage ? AppColors.error : AppColors.success,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    isShortage
                        ? '${AppStrings.paymentShortage}: ${formatRupiah(state.total - state.cashReceived)}'
                        : '${AppStrings.changeLabel}: ${formatRupiah(state.changeAmount)}',
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isShortage ? AppColors.error : AppColors.success,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
