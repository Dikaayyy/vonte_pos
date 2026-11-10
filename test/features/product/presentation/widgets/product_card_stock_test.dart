import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/core/constants/app_constants.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/core/widgets/stock_badge.dart';
import 'package:vonte_pos/features/product/domain/entities/product.dart';
import 'package:vonte_pos/features/product/presentation/widgets/product_card.dart';

void main() {
  Widget buildTestCard({required Product product}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 220,
            height: 380,
            child: ProductCard(
              product: product,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      ),
    );
  }

  Product createProduct({required int stock}) {
    return Product(
      id: 1,
      name: 'Matcha Latte',
      price: 22000,
      stock: stock,
      createdAt: 1000,
      updatedAt: 1000,
    );
  }

  group('ProductCard Stock Threshold & Non-Redundancy Tests', () {
    testWidgets(
        'tepat di ambang (stock == 5): shows "Sisa 5" badge and NO redundant "Stok: 5" in details row',
        (tester) async {
      final product = createProduct(stock: AppConstants.lowStockThreshold);
      await tester.pumpWidget(buildTestCard(product: product));
      await tester.pumpAndSettle();

      // Shows StockBadge with 'Sisa 5'
      expect(find.byType(StockBadge), findsOneWidget);
      expect(find.text('${AppStrings.lowStockPrefix} 5'), findsOneWidget);

      // Verify NO redundant 'Stok: 5' text in details row
      expect(find.text('${AppStrings.stockLabelPrefix} 5'), findsNothing);
    });

    testWidgets(
        'di atas ambang (stock == 6): NO "Sisa 6" badge, shows normal "Stok: 6" in details row',
        (tester) async {
      final product = createProduct(stock: AppConstants.lowStockThreshold + 1);
      await tester.pumpWidget(buildTestCard(product: product));
      await tester.pumpAndSettle();

      // No low stock badge
      expect(find.textContaining(AppStrings.lowStockPrefix), findsNothing);

      // Normal stock text should be displayed
      expect(find.text('${AppStrings.stockLabelPrefix} 6'), findsOneWidget);
    });

    testWidgets(
        'stok 0: shows "Habis" badge and NO redundant "Stok: 0" in details row',
        (tester) async {
      final product = createProduct(stock: 0);
      await tester.pumpWidget(buildTestCard(product: product));
      await tester.pumpAndSettle();

      // Shows 'Habis' badge
      expect(find.text(AppStrings.outOfStockBadge), findsOneWidget);

      // NO redundant text 'Stok: 0' in details row
      expect(find.text('${AppStrings.stockLabelPrefix} 0'), findsNothing);
    });
  });
}
