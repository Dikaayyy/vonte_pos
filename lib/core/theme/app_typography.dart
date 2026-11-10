import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography definitions from DESIGN.md.
/// Uses Manrope with tabular figures enabled for consistent number alignments.
abstract final class AppTypography {
  static const String fontFamily = 'Manrope';

  static const List<FontFeature> tabularFigures = [
    FontFeature.tabularFigures(),
  ];

  static const TextStyle totalDisplay = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32.0,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.64, // -0.02em * 32
    color: AppColors.onSurface,
    fontFeatures: tabularFigures,
  );

  static const TextStyle headlineLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    fontFeatures: tabularFigures,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    fontFeatures: tabularFigures,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    fontFeatures: tabularFigures,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
    fontFeatures: tabularFigures,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.0,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
    fontFeatures: tabularFigures,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    fontFeatures: tabularFigures,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceMuted,
    fontFeatures: tabularFigures,
  );

  static const TextStyle price = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15.0,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    fontFeatures: tabularFigures,
  );
}
