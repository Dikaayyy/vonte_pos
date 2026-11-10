import 'package:flutter/material.dart';

/// Design system color tokens from DESIGN.md (Vonte Soft Glass).
/// Light-mode only. No dark theme tokens.
abstract final class AppColors {
  // Page background & wash
  static const Color background = Color(0xFFEAF1F4);
  static const Color atmosTeal = Color(0xFF99F6E4);
  static const Color atmosSky = Color(0xFFBAE6FD);

  // Surfaces
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceGlass = Color(0x9EFFFFFF); // rgba(255, 255, 255, 0.62)
  static const Color surfaceGlassStrong = Color(0xCCFFFFFF); // rgba(255, 255, 255, 0.80)

  // Borders & Shadow
  static const Color borderGlass = Color(0xD9FFFFFF); // rgba(255, 255, 255, 0.85)
  static const Color borderHairline = Color(0x140F172A); // rgba(15, 23, 42, 0.08)
  static const Color shadow = Color(0x140F172A); // rgba(15, 23, 42, 0.08)

  // Primary Accent (Deep Teal)
  static const Color primary = Color(0xFF0F766E);
  static const Color primaryPressed = Color(0xFF115E59);
  static const Color primarySoft = Color(0xFFCCFBF1);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Text / Neutral tones
  static const Color onSurface = Color(0xFF0F172A);
  static const Color onSurfaceVariant = Color(0xFF475569);
  static const Color onSurfaceMuted = Color(0xFF5F6C7B);

  // Status Colors (Semantic only, never used as solid button/card fills)
  static const Color success = Color(0xFF15803D);
  static const Color successSoft = Color(0xFFDCFCE7);

  static const Color warning = Color(0xFFB45309);
  static const Color warningSoft = Color(0xFFFEF3C7);

  static const Color error = Color(0xFFB91C1C);
  static const Color errorSoft = Color(0xFFFEE2E2);
}

