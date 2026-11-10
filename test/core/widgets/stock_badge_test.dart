import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/core/constants/app_constants.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/core/theme/app_colors.dart';
import 'package:vonte_pos/core/widgets/stock_badge.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  group('StockBadge Threshold Boundary Tests', () {
    testWidgets('tepat di ambang (stock == 5): renders warning badge "Sisa 5"',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          StockBadge(stock: AppConstants.lowStockThreshold),
        ),
      );

      final badgeFinder = find.byType(StockBadge);
      expect(badgeFinder, findsOneWidget);
      expect(
        find.text('${AppStrings.lowStockPrefix} 5'),
        findsOneWidget,
      );

      // Verify warning styling
      final container = tester.widget<Container>(
        find.descendant(of: badgeFinder, matching: find.byType(Container)),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.warningSoft);
      expect(decoration.border?.top.color, AppColors.warning);
    });

    testWidgets('di atas ambang (stock == 6): renders empty SizedBox.shrink',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          StockBadge(stock: AppConstants.lowStockThreshold + 1),
        ),
      );

      expect(find.textContaining('Sisa'), findsNothing);
      expect(find.text(AppStrings.outOfStockBadge), findsNothing);

      // Verify that no non-zero sized Container is rendered
      final containerFinder = find.descendant(
        of: find.byType(StockBadge),
        matching: find.byType(Container),
      );
      expect(containerFinder, findsNothing);
    });

    testWidgets('stok 0: renders error badge "Habis"', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          StockBadge(stock: 0),
        ),
      );

      final badgeFinder = find.byType(StockBadge);
      expect(badgeFinder, findsOneWidget);
      expect(find.text(AppStrings.outOfStockBadge), findsOneWidget);

      // Verify error styling
      final container = tester.widget<Container>(
        find.descendant(of: badgeFinder, matching: find.byType(Container)),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.errorSoft);
      expect(decoration.border?.top.color, AppColors.error);
    });

    testWidgets('stok negatif (-1): renders error badge "Habis"', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          StockBadge(stock: -1),
        ),
      );

      expect(find.text(AppStrings.outOfStockBadge), findsOneWidget);
    });

    testWidgets('di bawah ambang (stock == 1): renders warning badge "Sisa 1"',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          StockBadge(stock: 1),
        ),
      );

      expect(
        find.text('${AppStrings.lowStockPrefix} 1'),
        findsOneWidget,
      );
    });

    testWidgets('StockBadge.cartFull renders "Stok sudah di keranjang"',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const StockBadge.cartFull(),
        ),
      );

      expect(find.text(AppStrings.stockAlreadyInCart), findsOneWidget);
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(StockBadge),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.warningSoft);
    });

    testWidgets('custom threshold overrides default threshold', (tester) async {
      // Stock is 8, threshold is 10 -> should show "Sisa 8"
      await tester.pumpWidget(
        buildTestableWidget(
          StockBadge(stock: 8, threshold: 10),
        ),
      );
      expect(find.text('${AppStrings.lowStockPrefix} 8'), findsOneWidget);

      // Stock is 11, threshold is 10 -> should be hidden
      await tester.pumpWidget(
        buildTestableWidget(
          StockBadge(stock: 11, threshold: 10),
        ),
      );
      expect(find.textContaining('Sisa'), findsNothing);
    });
  });
}

