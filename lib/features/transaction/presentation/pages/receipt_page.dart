import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_glass.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/transaction.dart';
import '../widgets/receipt_view.dart';

/// Full-page receipt preview screen displayed immediately after checkout
/// or when viewing transaction details from history.
class ReceiptPage extends StatelessWidget {
  final Transaction transaction;
  final String? customFooter;
  final VoidCallback? onDone;

  const ReceiptPage({
    super.key,
    required this.transaction,
    this.customFooter,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    tooltip: AppStrings.close,
                    onPressed: onDone ?? () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    AppStrings.receiptTitle,
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
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.gutterCompact),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ReceiptView(
                    transaction: transaction,
                    customFooter: customFooter,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Action Buttons
                  Row(
                    children: [
                      // Cetak: Secondary button, disabled placeholder until Bluetooth thermal printer feature is added
                      Expanded(
                        child: AppButton(
                          text: AppStrings.printButton,
                          variant: AppButtonVariant.secondary,
                          leadingIcon: const Icon(Icons.print_outlined, size: 20),
                          onPressed: null, // Disabled placeholder
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Selesai: Primary button, finishes the checkout flow
                      Expanded(
                        child: AppButton(
                          text: AppStrings.finishButton,
                          variant: AppButtonVariant.primary,
                          isLarge: true,
                          onPressed: onDone ?? () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
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
