import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/core/theme/app_colors.dart';
import 'package:vonte_pos/core/theme/app_radius.dart';
import 'package:vonte_pos/core/theme/app_sizes.dart';
import 'package:vonte_pos/core/theme/app_spacing.dart';
import 'package:vonte_pos/core/theme/app_theme.dart';
import 'package:vonte_pos/core/theme/app_typography.dart';

void main() {
  group('AppColors', () {
    test('contains exact color values matching DESIGN.md', () {
      expect(AppColors.background, const Color(0xFFEAF1F4));
      expect(AppColors.atmosTeal, const Color(0xFF99F6E4));
      expect(AppColors.atmosSky, const Color(0xFFBAE6FD));
      expect(AppColors.surfaceCard, const Color(0xFFFFFFFF));
      expect(AppColors.primary, const Color(0xFF0F766E));
      expect(AppColors.primaryPressed, const Color(0xFF115E59));
      expect(AppColors.primarySoft, const Color(0xFFCCFBF1));
      expect(AppColors.onPrimary, const Color(0xFFFFFFFF));
      expect(AppColors.onSurface, const Color(0xFF0F172A));
      expect(AppColors.onSurfaceVariant, const Color(0xFF475569));
      expect(AppColors.onSurfaceMuted, const Color(0xFF5F6C7B));
      expect(AppColors.success, const Color(0xFF15803D));
      expect(AppColors.warning, const Color(0xFFB45309));
      expect(AppColors.error, const Color(0xFFB91C1C));
    });
  });

  group('AppRadius', () {
    test('contains exact radius values matching DESIGN.md', () {
      expect(AppRadius.sm, 8.0);
      expect(AppRadius.md, 12.0);
      expect(AppRadius.lg, 16.0);
      expect(AppRadius.xl, 24.0);
      expect(AppRadius.full, 9999.0);
    });
  });

  group('AppSpacing', () {
    test('contains exact spacing values matching DESIGN.md', () {
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.sm, 8.0);
      expect(AppSpacing.md, 12.0);
      expect(AppSpacing.lg, 16.0);
      expect(AppSpacing.xl, 24.0);
      expect(AppSpacing.gutterCompact, 16.0);
      expect(AppSpacing.gutterExpanded, 24.0);
    });
  });

  group('AppSizes', () {
    test('contains touch minimum and button heights from DESIGN.md', () {
      expect(AppSizes.touchMin, 48.0);
      expect(AppSizes.buttonHeight, 52.0);
      expect(AppSizes.buttonHeightPrimary, 56.0);
      expect(AppSizes.glassSigma, 16.0);
      expect(AppSizes.maxSimultaneousBlurLayers, 3);
    });
  });

  group('AppTypography', () {
    test('includes tabular figures font feature on all styles', () {
      const expectedFeature = FontFeature.tabularFigures();

      for (final style in [
        AppTypography.totalDisplay,
        AppTypography.headlineLg,
        AppTypography.headlineMd,
        AppTypography.title,
        AppTypography.bodyMd,
        AppTypography.bodySm,
        AppTypography.label,
        AppTypography.caption,
        AppTypography.price,
      ]) {
        expect(style.fontFamily, 'Manrope');
        expect(style.fontFeatures, contains(expectedFeature));
      }
    });

    test('verifies totalDisplay attributes from DESIGN.md', () {
      expect(AppTypography.totalDisplay.fontSize, 32.0);
      expect(AppTypography.totalDisplay.fontWeight, FontWeight.w800);
      expect(AppTypography.totalDisplay.letterSpacing, -0.64);
    });
  });

  group('AppTheme', () {
    test('configures light theme correctly and strictly without dark mode', () {
      final theme = AppTheme.lightTheme;

      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.surface, AppColors.surfaceCard);
      expect(theme.colorScheme.error, AppColors.error);
      expect(theme.useMaterial3, isTrue);
    });
  });
}

