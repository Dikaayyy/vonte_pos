import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/core/constants/app_constants.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/core/widgets/stock_badge.dart';
import 'package:vonte_pos/features/cashier/presentation/widgets/cashier_product_card.dart';
import 'package:vonte_pos/features/product/domain/entities/product.dart';

void main() {
  Widget buildTestCard({
    required Product product,
    int unitsInCart = 0,
    VoidCallback? onTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 180,
            height: 240,
            child: CashierProductCard(
              product: product,
              unitsInCart: unitsInCart,
              onTap: onTap ?? () {},
            ),
          ),
        ),
      ),
    );
  }

  Product createProduct({required int stock}) {
    return Product(
      id: 1,
      name: 'Kopi Kenangan',
      price: 18000,
      stock: stock,
      createdAt: 1000,
      updatedAt: 1000,
    );
  }

  group('CashierProductCard Stock Threshold & Non-Redundancy Tests', () {
    testWidgets(
        'tepat di ambang (stock == 5, unitsInCart == 0): shows "Sisa 5" badge and NO redundant "Stok: 5" indicator',
        (tester) async {
      final product = createProduct(stock: AppConstants.lowStockThreshold);
      await tester.pumpWidget(buildTestCard(product: product));
      await tester.pumpAndSettle();

      // Badge 'Sisa 5' exists exactly once on the card
      expect(find.byType(StockBadge), findsOneWidget);
      expect(find.text('${AppStrings.lowStockPrefix} 5'), findsOneWidget);

      // Verify NO redundant 'Stok: 5' text on the card
      expect(find.text('${AppStrings.stockLabelPrefix} 5'), findsNothing);
    });

    testWidgets(
        'di atas ambang (stock == 6, unitsInCart == 0): NO low-stock badge, shows normal "Stok: 6"',
        (tester) async {
      final product = createProduct(stock: AppConstants.lowStockThreshold + 1);
      await tester.pumpWidget(buildTestCard(product: product));
      await tester.pumpAndSettle();

      // Low stock badge should NOT be rendered
      expect(find.textContaining(AppStrings.lowStockPrefix), findsNothing);

      // Normal stock text should be displayed
      expect(find.text('${AppStrings.stockLabelPrefix} 6'), findsOneWidget);
    });

    testWidgets(
        'stok di atas ambang tapi keranjang menyisakan stok menipis (stock: 8, unitsInCart: 5): shows "Sisa 3" badge and NO redundant "Stok: 3"',
        (tester) async {
      final product = createProduct(stock: 8);
      await tester.pumpWidget(
        buildTestCard(product: product, unitsInCart: 5),
      );
      await tester.pumpAndSettle();

      // Badge shows remaining 3
      expect(find.text('${AppStrings.lowStockPrefix} 3'), findsOneWidget);

      // Redundant text 'Stok: 3' is NOT rendered
      expect(find.text('${AppStrings.stockLabelPrefix} 3'), findsNothing);
    });

    testWidgets(
        'stok 0: shows "Habis" badge, not tappable, NO redundant "Stok habis." or "Stok: 0"',
        (tester) async {
      var tapped = false;
      final product = createProduct(stock: 0);
      await tester.pumpWidget(
        buildTestCard(
          product: product,
          onTap: () => tapped = true,
        ),
      );
      await tester.pumpAndSettle();

      // Shows 'Habis' badge
      expect(find.text(AppStrings.outOfStockBadge), findsOneWidget);

      // NO redundant text below price
      expect(find.text(AppStrings.stockExhaustedGeneral), findsNothing);
      expect(find.text('${AppStrings.stockLabelPrefix} 0'), findsNothing);

      // Not tappable
      await tester.tap(find.byType(CashierProductCard));
      await tester.pumpAndSettle();
      expect(tapped, isFalse);
    });

    testWidgets(
        'stok penuh di keranjang (stock: 4, unitsInCart: 4): shows "Stok sudah di keranjang" badge and NO redundant text',
        (tester) async {
      var tapped = false;
      final product = createProduct(stock: 4);
      await tester.pumpWidget(
        buildTestCard(
          product: product,
          unitsInCart: 4,
          onTap: () => tapped = true,
        ),
      );
      await tester.pumpAndSettle();

      // Shows badge exactly once
      expect(find.text(AppStrings.stockAlreadyInCart), findsOneWidget);

      // NO redundant text
      expect(find.text('${AppStrings.stockLabelPrefix} 0'), findsNothing);

      // Not tappable
      await tester.tap(find.byType(CashierProductCard));
      await tester.pumpAndSettle();
      expect(tapped, isFalse);
    });
  });
}

