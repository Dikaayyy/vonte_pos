import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';

/// Solid card widget for repeated content (products, list items, receipts).
/// As specified in DESIGN.md, cards do NOT use glass/BackdropFilter.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.borderRadius,
    this.color,
    this.border,
    this.hasShadow = true,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final BoxBorder? border;
  final bool hasShadow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppRadius.borderRadiusLg;
    final effectiveColor = color ?? AppColors.surfaceCard;

    Widget current = Padding(padding: padding, child: child);

    if (onTap != null) {
      current = Material(
        color: Colors.transparent,
        borderRadius: effectiveRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          splashColor: AppColors.primarySoft.withValues(alpha: 0.4),
          highlightColor: AppColors.primarySoft.withValues(alpha: 0.2),
          child: current,
        ),
      );
    }

    final cardDecoration = BoxDecoration(
      color: effectiveColor,
      borderRadius: effectiveRadius,
      border: border ?? Border.all(color: AppColors.borderHairline, width: 1),
      boxShadow: hasShadow
          ? const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ]
          : null,
    );

    Widget result = DecoratedBox(
      decoration: cardDecoration,
      child: current,
    );

    if (margin != null) {
      result = Padding(padding: margin!, child: result);
    }

    return result;
  }
}
