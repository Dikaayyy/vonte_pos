import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_sizes.dart';
import '../theme/app_typography.dart';

/// Pill-shaped quantity stepper with tabular numerals and inline stock reason.
/// Complies with:
/// - Pill shape (rounded.full)
/// - Buttons at least 40x40 with 48dp minimum touch target
/// - Tabular figures on quantity display
/// - Inline reason shown when plus or minus is blocked
class QtyStepper extends StatelessWidget {
  const QtyStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max,
    this.disabledReason,
    this.compact = false,
  });

  final int value;
  final ValueChanged<int>? onChanged;
  final int min;
  final int? max;

  /// Explanatory message displayed inline when the maximum limit is reached.
  final String? disabledReason;

  /// Slightly more compact styling if needed in dense lists.
  final bool compact;

  bool get _canDecrease => onChanged != null && value > min;
  bool get _canIncrease => onChanged != null && (max == null || value < max!);

  void _handleDecrease() {
    if (_canDecrease) {
      onChanged!(value - 1);
    }
  }

  void _handleIncrease() {
    if (_canIncrease) {
      onChanged!(value + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double buttonSize = compact ? 36.0 : 40.0;
    final double touchHeight = AppSizes.touchMin;

    final pillWidget = Container(
      height: touchHeight,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.borderRadiusFull,
        border: Border.all(color: AppColors.borderHairline, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Minus button
          Semantics(
            label: AppStrings.decreaseQty,
            button: true,
            enabled: _canDecrease,
            child: SizedBox(
              width: touchHeight,
              height: touchHeight,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: compact ? 18.0 : 20.0,
                constraints: BoxConstraints(
                  minWidth: buttonSize,
                  minHeight: buttonSize,
                ),
                onPressed: _canDecrease ? _handleDecrease : null,
                icon: const Icon(Icons.remove_rounded),
                color: AppColors.onSurface,
                disabledColor: AppColors.onSurfaceMuted.withValues(alpha: 0.35),
                splashRadius: 20,
              ),
            ),
          ),

          // Value with tabular figures
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 32.0),
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: AppTypography.title.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                fontFeatures: AppTypography.tabularFigures,
              ),
            ),
          ),

          // Plus button
          Semantics(
            label: AppStrings.increaseQty,
            button: true,
            enabled: _canIncrease,
            child: SizedBox(
              width: touchHeight,
              height: touchHeight,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: compact ? 18.0 : 20.0,
                constraints: BoxConstraints(
                  minWidth: buttonSize,
                  minHeight: buttonSize,
                ),
                onPressed: _canIncrease ? _handleIncrease : null,
                icon: const Icon(Icons.add_rounded),
                color: AppColors.onSurface,
                disabledColor: AppColors.onSurfaceMuted.withValues(alpha: 0.35),
                splashRadius: 20,
              ),
            ),
          ),
        ],
      ),
    );

    // If disabled reason is present and plus cannot be pressed, display inline explanation
    final showInlineReason = !_canIncrease &&
        disabledReason != null &&
        disabledReason!.trim().isNotEmpty;

    if (!showInlineReason) {
      return pillWidget;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        pillWidget,
        const SizedBox(height: 4),
        Text(
          disabledReason!,
          style: AppTypography.caption.copyWith(
            color: AppColors.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
