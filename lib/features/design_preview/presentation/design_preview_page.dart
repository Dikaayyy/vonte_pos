// TEMP: Design preview page for evaluating design system tokens and shared widgets.
// Marked with TEMP comments so it can be easily removed when feature pages are integrated.

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_button.dart';
import '../../../../core/theme/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_glass.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/inline_error.dart';
import '../../../../core/widgets/qty_stepper.dart';

class DesignPreviewPage extends StatefulWidget {
  const DesignPreviewPage({super.key});

  // TEMP route name
  static const String routeName = '/design-preview';

  @override
  State<DesignPreviewPage> createState() => _DesignPreviewPageState();
}

class _DesignPreviewPageState extends State<DesignPreviewPage> {
  int _interactiveQty = 2;
  final int _maxStockQty = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background wash with at most two soft blurred circles (DESIGN.md)
          Positioned(
            top: -60,
            left: -60,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.atmosTeal.withValues(alpha: 0.30),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            right: -80,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.atmosSky.withValues(alpha: 0.30),
                ),
              ),
            ),
          ),

          // Main scrollable content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutterCompact,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  const Text(
                    AppStrings.designPreviewTitle,
                    style: AppTypography.headlineLg,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    AppStrings.designPreviewSubtitle,
                    style: AppTypography.bodySm,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Fallback Solid Blur Switch Control
                  ValueListenableBuilder<bool>(
                    valueListenable: AppGlass.disableBlurNotifier,
                    builder: (context, isBlurDisabled, _) {
                      return AppCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.glassToggleBlur,
                                    style: AppTypography.title,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    AppStrings.glassToggleBlurDesc,
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: isBlurDisabled,
                              activeTrackColor: AppColors.primary,
                              onChanged: (val) {
                                AppGlass.disableBlur = val;
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // 1. Typography Section
                  _buildSectionHeader(AppStrings.sectionTypography),
                  const AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.sampleTotalDisplay, style: AppTypography.totalDisplay),
                        SizedBox(height: AppSpacing.xs),
                        Text(AppStrings.samplePrice, style: AppTypography.price),
                        SizedBox(height: AppSpacing.sm),
                        Text(AppStrings.sampleHeadlineLg, style: AppTypography.headlineLg),
                        SizedBox(height: AppSpacing.xs),
                        Text(AppStrings.sampleHeadlineMd, style: AppTypography.headlineMd),
                        SizedBox(height: AppSpacing.xs),
                        Text(AppStrings.sampleTitle, style: AppTypography.title),
                        SizedBox(height: AppSpacing.xs),
                        Text(AppStrings.sampleBodyMd, style: AppTypography.bodyMd),
                        SizedBox(height: AppSpacing.xs),
                        Text(AppStrings.sampleBodySm, style: AppTypography.bodySm),
                        SizedBox(height: AppSpacing.xs),
                        Text(AppStrings.sampleLabel, style: AppTypography.label),
                        SizedBox(height: AppSpacing.xs),
                        Text(AppStrings.sampleCaption, style: AppTypography.caption),
                        Divider(height: AppSpacing.xl),
                        Text(AppStrings.tabularTestLabel, style: AppTypography.caption),
                        SizedBox(height: 4),
                        Text(AppStrings.tabularSampleA, style: AppTypography.headlineMd),
                        Text(AppStrings.tabularSampleB, style: AppTypography.headlineMd),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // 2. AppGlass Section
                  _buildSectionHeader(AppStrings.sectionGlass),
                  const AppGlass(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.glassDefaultLabel, style: AppTypography.title),
                        SizedBox(height: AppSpacing.xs),
                        Text(AppStrings.sampleBodyMd, style: AppTypography.bodyMd),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const AppGlass(
                    isStrong: true,
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.glassStrongLabel, style: AppTypography.title),
                        SizedBox(height: AppSpacing.xs),
                        Text(AppStrings.sampleBodyMd, style: AppTypography.bodyMd),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const AppGlass(
                    isAccent: true,
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.glassAccentLabel, style: AppTypography.title),
                        SizedBox(height: AppSpacing.xs),
                        Text(AppStrings.sampleBodyMd, style: AppTypography.bodyMd),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // 3. AppCard Section
                  _buildSectionHeader(AppStrings.sectionCard),
                  AppCard(
                    onTap: () {},
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.cardTitleSample, style: AppTypography.title),
                        SizedBox(height: AppSpacing.xs),
                        Text(AppStrings.cardSubtitleSample, style: AppTypography.bodyMd),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // 4. AppButton Section
                  _buildSectionHeader(AppStrings.sectionButtons),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      AppButton(
                        text: AppStrings.buttonPrimaryLabel,
                        variant: AppButtonVariant.primary,
                        onPressed: () {},
                      ),
                      AppButton(
                        text: AppStrings.buttonPrimaryLargeLabel,
                        variant: AppButtonVariant.primary,
                        isLarge: true,
                        onPressed: () {},
                      ),
                      AppButton(
                        text: AppStrings.buttonSecondaryLabel,
                        variant: AppButtonVariant.secondary,
                        onPressed: () {},
                      ),
                      AppButton(
                        text: AppStrings.buttonDestructiveLabel,
                        variant: AppButtonVariant.destructive,
                        onPressed: () {},
                      ),
                      AppButton(
                        text: AppStrings.buttonDestructiveSolidLabel,
                        variant: AppButtonVariant.destructive,
                        isSolidDestructive: true,
                        onPressed: () {},
                      ),
                      AppButton(
                        text: AppStrings.buttonTextLabel,
                        variant: AppButtonVariant.text,
                        onPressed: () {},
                      ),
                      const AppButton(
                        text: AppStrings.buttonDisabledLabel,
                        variant: AppButtonVariant.primary,
                        onPressed: null,
                      ),
                      AppButton(
                        text: AppStrings.buttonLoadingLabel,
                        variant: AppButtonVariant.primary,
                        isLoading: true,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // 5. QtyStepper Section
                  _buildSectionHeader(AppStrings.sectionStepper),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(AppStrings.sampleTitle, style: AppTypography.title),
                        const SizedBox(height: AppSpacing.sm),
                        QtyStepper(
                          value: _interactiveQty,
                          min: 1,
                          max: _maxStockQty,
                          disabledReason: _interactiveQty >= _maxStockQty
                              ? AppStrings.sampleErrorMessage
                              : null,
                          onChanged: (newVal) {
                            setState(() {
                              _interactiveQty = newVal;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // 6. InlineError Section
                  _buildSectionHeader(AppStrings.sectionInlineError),
                  const InlineError(
                    message: AppStrings.sampleErrorMessage,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // 7. EmptyState Section
                  _buildSectionHeader(AppStrings.sectionEmptyState),
                  AppCard(
                    child: EmptyState(
                      icon: Icons.shopping_bag_outlined,
                      title: AppStrings.emptyCartTitle,
                      message: AppStrings.emptyCartSubtitle,
                      action: AppButton(
                        text: AppStrings.add,
                        variant: AppButtonVariant.primary,
                        onPressed: () {},
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTypography.headlineMd.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
