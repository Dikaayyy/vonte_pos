import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_sizes.dart';
import 'app_typography.dart';

enum AppButtonVariant {
  primary,
  secondary,
  destructive,
  text,
}

/// Standard button widget implementing the four variants from DESIGN.md:
/// primary, secondary, destructive, and text.
///
/// Complies with:
/// - 48dp+ tap target minimum
/// - 52dp standard height / 56dp primary large height
/// - Rounded MD (12px)
/// - No gradients, no component glow
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLarge = false,
    this.fullWidth = false,
    this.isLoading = false,
    this.isSolidDestructive = false,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLarge;
  final bool fullWidth;
  final bool isLoading;

  /// If true and variant is destructive, renders solid error background with white text (for final dialog confirms).
  final bool isSolidDestructive;

  final Widget? leadingIcon;
  final Widget? trailingIcon;

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final double height = (variant == AppButtonVariant.primary && isLarge)
        ? AppSizes.buttonHeightPrimary
        : AppSizes.buttonHeight;

    final Color backgroundColor;
    final Color foregroundColor;
    final BorderSide? borderSide;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = _isEnabled
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.40);
        foregroundColor = AppColors.onPrimary;
        borderSide = null;
        break;

      case AppButtonVariant.secondary:
        backgroundColor = _isEnabled
            ? AppColors.surfaceCard
            : AppColors.surfaceCard.withValues(alpha: 0.50);
        foregroundColor = _isEnabled
            ? AppColors.onSurface
            : AppColors.onSurfaceMuted;
        borderSide = const BorderSide(color: AppColors.borderHairline, width: 1);
        break;

      case AppButtonVariant.destructive:
        if (isSolidDestructive) {
          backgroundColor = _isEnabled
              ? AppColors.error
              : AppColors.error.withValues(alpha: 0.40);
          foregroundColor = AppColors.onPrimary;
          borderSide = null;
        } else {
          backgroundColor = _isEnabled
              ? AppColors.surfaceCard
              : AppColors.surfaceCard.withValues(alpha: 0.50);
          foregroundColor = _isEnabled
              ? AppColors.error
              : AppColors.error.withValues(alpha: 0.40);
          borderSide = BorderSide(
            color: _isEnabled
                ? AppColors.error
                : AppColors.error.withValues(alpha: 0.30),
            width: 1,
          );
        }
        break;

      case AppButtonVariant.text:
        backgroundColor = Colors.transparent;
        foregroundColor = _isEnabled
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.40);
        borderSide = null;
        break;
    }

    final textStyle = AppTypography.label.copyWith(
      color: foregroundColor,
      fontWeight: FontWeight.w600,
    );

    Widget content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (leadingIcon != null) ...[
          leadingIcon!,
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: textStyle,
          textAlign: TextAlign.center,
        ),
        if (!isLoading && trailingIcon != null) ...[
          const SizedBox(width: 8),
          trailingIcon!,
        ],
      ],
    );

    final shape = RoundedRectangleBorder(
      borderRadius: AppRadius.borderRadiusMd,
      side: borderSide ?? BorderSide.none,
    );

    Widget buttonWidget;
    if (variant == AppButtonVariant.text) {
      buttonWidget = TextButton(
        onPressed: _isEnabled ? onPressed : null,
        style: TextButton.styleFrom(
          foregroundColor: foregroundColor,
          minimumSize: Size(fullWidth ? double.infinity : AppSizes.touchMin, height),
          shape: shape,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: content,
      );
    } else {
      buttonWidget = ElevatedButton(
        onPressed: _isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor,
          disabledForegroundColor: foregroundColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: Size(fullWidth ? double.infinity : AppSizes.touchMin, height),
          shape: shape,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: content,
      );
    }

    // Ensure minimum touch target constraint
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: AppSizes.touchMin,
        minWidth: fullWidth ? double.infinity : AppSizes.touchMin,
      ),
      child: buttonWidget,
    );
  }
}
