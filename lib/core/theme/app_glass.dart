import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_sizes.dart';

/// Reusable glass surface widget complying with DESIGN.md specifications.
/// Structure: ClipRRect + BackdropFilter(sigma: 16) + DecoratedBox.
///
/// Features a single switch [disableBlur] to fall back to solid
/// surface without blur for low-end devices and performance critical frames.
class AppGlass extends StatelessWidget {
  const AppGlass({
    super.key,
    this.child,
    this.padding,
    this.borderRadius,
    this.color,
    this.border,
    this.isStrong = false,
    this.isAccent = false,
    this.hasShadow = true,
    this.fallbackSolid,
  });

  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? color;
  final BoxBorder? border;
  final bool isStrong;
  final bool isAccent;
  final bool hasShadow;

  /// Per-instance override for fallback solid mode.
  /// If null, uses global [disableBlur].
  final bool? fallbackSolid;

  /// Global switch for fallback solid mode.
  /// When true, all AppGlass instances render solid surfaces without BackdropFilter.
  static final ValueNotifier<bool> disableBlurNotifier = ValueNotifier<bool>(false);

  static bool get disableBlur => disableBlurNotifier.value;
  static set disableBlur(bool value) {
    disableBlurNotifier.value = value;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: disableBlurNotifier,
      builder: (context, globalDisable, _) {
        final effectiveDisableBlur = fallbackSolid ?? globalDisable;
        final effectiveRadius = borderRadius ?? AppRadius.borderRadiusLg;

        final Color effectiveFillColor;
        if (color != null) {
          effectiveFillColor = color!;
        } else if (isAccent) {
          effectiveFillColor = effectiveDisableBlur
              ? AppColors.primarySoft
              : AppColors.primarySoft.withValues(alpha: 0.75);
        } else if (isStrong) {
          effectiveFillColor = AppColors.surfaceGlassStrong;
        } else {
          effectiveFillColor = effectiveDisableBlur
              ? AppColors.surfaceGlassStrong
              : AppColors.surfaceGlass;
        }

        final innerDecoration = BoxDecoration(
          color: effectiveFillColor,
          borderRadius: effectiveRadius,
          border: border ?? Border.all(color: AppColors.borderHairline, width: 1),
        );

        Widget content = child ?? const SizedBox.shrink();
        if (padding != null) {
          content = Padding(padding: padding!, child: content);
        }

        final Widget glassBody = isEffectiveNoBlur(effectiveDisableBlur)
            ? DecoratedBox(
                decoration: innerDecoration,
                child: content,
              )
            : BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: AppSizes.glassSigma,
                  sigmaY: AppSizes.glassSigma,
                ),
                child: DecoratedBox(
                  decoration: innerDecoration,
                  child: content,
                ),
              );

        Widget result = ClipRRect(
          borderRadius: effectiveRadius,
          child: glassBody,
        );

        if (hasShadow) {
          result = DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: effectiveRadius,
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: result,
          );
        }

        return result;
      },
    );
  }

  bool isEffectiveNoBlur(bool disabled) => disabled;
}
