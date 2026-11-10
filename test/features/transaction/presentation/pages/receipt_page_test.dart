import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/core/theme/app_theme.dart';
import 'package:vonte_pos/features/transaction/domain/entities/transaction.dart';
import 'package:vonte_pos/features/transaction/domain/entities/transaction_item.dart';
import 'package:vonte_pos/features/transaction/domain/entities/transaction_item_addon.dart';
import 'package:vonte_pos/features/transaction/presentation/pages/receipt_page.dart';
import 'package:vonte_pos/features/transaction/presentation/widgets/receipt_view.dart';

void main() {
  const sampleTransaction = Transaction(
    id: 42,
    invoiceNo: 'VNT-20261110-0001',
    cashierId: 1,
    cashierName: 'Budi Kasir',
    storeName: 'Vonte Coffee & Bakery',
    storeAddress: 'Jl. Sudirman No. 10',
    storePhone: '081234567890',
    subtotal: 55000,
    discountType: 'percent',
    discountValue: 10,
    discountAmount: 5500,
    total: 49500,
    cashReceived: 50000,
    changeAmount: 500,
    createdAt: 1700000000000,
    items: [
      TransactionItem(
        productId: 1,
        productName: 'Kopi Susu Aren',
        unitPrice: 20000,
        qty: 2,
        lineTotal: 40000,
        addons: [
          TransactionItemAddon(
            addonId: 10,
            addonName: 'Extra Shot',
            addonPrice: 5000,
            qty: 2,
            lineTotal: 10000,
          ),
        ],
      ),
      TransactionItem(
        productId: 2,
        productName: 'Roti Cokelat',
        unitPrice: 15000,
        qty: 1,
        lineTotal: 15000,
      ),
    ],
  );

  Widget createWidget({VoidCallback? onDone, String? customFooter}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: ReceiptPage(
        transaction: sampleTransaction,
        onDone: onDone,
        customFooter: customFooter,
      ),
    );
  }

  testWidgets('ReceiptView renders store details, invoice, and cashier name', (tester) async {
    await tester.pumpWidget(createWidget());

    expect(find.text('Vonte Coffee & Bakery'), findsOneWidget);
    expect(find.text('Jl. Sudirman No. 10'), findsOneWidget);
    expect(find.text('081234567890'), findsOneWidget);
    expect(find.text('VNT-20261110-0001'), findsOneWidget);
    expect(find.text('Budi Kasir'), findsOneWidget);
  });

  testWidgets('ReceiptView renders items and indented add-on lines with proper formatting', (tester) async {
    await tester.pumpWidget(createWidget());

    expect(find.text('Kopi Susu Aren'), findsOneWidget);
    expect(find.text('2 x Rp20.000'), findsOneWidget);
    expect(find.text('Rp40.000'), findsOneWidget);

    expect(find.text('+ Extra Shot (2x Rp5.000)'), findsOneWidget);
    expect(find.text('Rp10.000'), findsOneWidget);

    expect(find.text('Roti Cokelat'), findsOneWidget);
    expect(find.text('1 x Rp15.000'), findsOneWidget);
    expect(find.text('Rp15.000'), findsOneWidget);
  });

  testWidgets('ReceiptView renders subtotal, discount, total, cash received, and change', (tester) async {
    await tester.pumpWidget(createWidget());

    expect(find.text('Rp55.000'), findsOneWidget); // Subtotal
    expect(find.text('-Rp5.500'), findsOneWidget); // Diskon
    expect(find.text('Rp49.500'), findsOneWidget); // Total
    expect(find.text('Rp50.000'), findsOneWidget); // Tunai
    expect(find.text('Rp500'), findsOneWidget); // Kembalian
  });

  testWidgets('ReceiptPage renders custom footer note when provided', (tester) async {
    await tester.pumpWidget(createWidget(customFooter: 'Simpan struk ini sebagai bukti'));

    expect(find.text('Simpan struk ini sebagai bukti'), findsOneWidget);
  });

  testWidgets('ReceiptPage has disabled "Cetak" button placeholder and active "Selesai" button', (tester) async {
    bool doneCalled = false;
    await tester.pumpWidget(createWidget(onDone: () => doneCalled = true));

    // Cetak button is disabled placeholder
    final printButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, AppStrings.printButton),
    );
    expect(printButton.onPressed, isNull);

    // Selesai button is enabled and taps successfully
    final finishButton = find.widgetWithText(ElevatedButton, AppStrings.finishButton);
    expect(finishButton, findsOneWidget);

    await tester.ensureVisible(finishButton);
    await tester.pumpAndSettle();
    await tester.tap(finishButton);
    await tester.pumpAndSettle();

    expect(doneCalled, isTrue);
  });

  testWidgets('ReceiptView uses solid surface-card background and no glassmorphism', (tester) async {
    await tester.pumpWidget(createWidget());

    expect(find.byType(ReceiptView), findsOneWidget);
    // Ensure no BackdropFilter is inside ReceiptView
    expect(
      find.descendant(
        of: find.byType(ReceiptView),
        matching: find.byType(BackdropFilter),
      ),
      findsNothing,
    );
  });
}

