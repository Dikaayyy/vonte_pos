import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_glass.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Representation of a single navigation destination item in AppShell.
class AppShellDestinationItem {
  const AppShellDestinationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Floating frosted glass bottom bar complying with DESIGN.md specifications.
/// - Sized at 64dp height with xl (24dp) border radius.
/// - Active item uses filled icon and primary color (#0F766E).
/// - Inactive item uses outline icon and on-surface-variant color.
/// - Touch target >= 48dp on each item.
class FloatingGlassBottomBar extends StatelessWidget {
  const FloatingGlassBottomBar({
    super.key,
    required this.currentIndex,
    required this.destinations,
    required this.onTap,
  });

  final int currentIndex;
  final List<AppShellDestinationItem> destinations;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return AppGlass(
      isStrong: true,
      borderRadius: AppRadius.borderRadiusXl,
      child: SizedBox(
        height: AppSizes.navBarHeight,
        child: Row(
          children: [
            for (int i = 0; i < destinations.length; i++)
              Expanded(
                child: _BottomNavItem(
                  index: i,
                  isSelected: currentIndex == i,
                  item: destinations[i],
                  onTap: () => onTap(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.index,
    required this.isSelected,
    required this.item,
    required this.onTap,
  });

  final int index;
  final bool isSelected;
  final AppShellDestinationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.primary;
    final inactiveColor = AppColors.onSurfaceVariant;
    final color = isSelected ? activeColor : inactiveColor;

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderRadiusXl,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizes.touchMin),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  size: 24,
                  color: color,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.label,
                  style: AppTypography.caption.copyWith(
                    color: color,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

