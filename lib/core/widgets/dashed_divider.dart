import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Renders a horizontal dashed divider line, ideal for receipt separators.
class DashedDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double dashWidth;
  final double dashSpace;

  const DashedDivider({
    super.key,
    this.height = 1,
    this.color = AppColors.borderHairline,
    this.dashWidth = 5,
    this.dashSpace = 3,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        if (boxWidth <= 0 || boxWidth.isInfinite) {
          return Divider(height: height, color: color);
        }
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (_) {
              return SizedBox(
                width: dashWidth,
                height: height,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

