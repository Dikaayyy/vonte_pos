/// Component sizes, breakpoints, and blur limits from DESIGN.md.
abstract final class AppSizes {
  // Touch & Component Sizes
  static const double touchMin = 48.0;
  static const double buttonHeight = 52.0;
  static const double buttonHeightPrimary = 56.0;
  static const double chipHeight = 40.0;
  static const double navBarHeight = 64.0;
  static const double cartPanelWidth = 380.0;

  // Breakpoints
  static const double compactBreakpoint = 600.0;
  static const double expandedBreakpoint = 840.0;

  // Blur Limits
  static const double glassSigma = 16.0;
  static const int maxSimultaneousBlurLayers = 3;
}

