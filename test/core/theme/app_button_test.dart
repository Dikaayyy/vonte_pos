import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/core/theme/app_button.dart';
import 'package:vonte_pos/core/theme/app_sizes.dart';

void main() {
  group('AppButton', () {
    testWidgets('triggers onPressed when clicked', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Bayar',
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Bayar'));
      expect(pressed, isTrue);
    });

    testWidgets('does not trigger callback when disabled', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Nonaktif',
              onPressed: null,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Nonaktif'));
      expect(pressed, isFalse);
    });

    testWidgets('displays loading indicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Memproses',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('respects minimum 48dp touch height constraint',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Touch Target Test',
              variant: AppButtonVariant.primary,
              onPressed: () {},
            ),
          ),
        ),
      );

      final buttonSize = tester.getSize(find.byType(AppButton));
      expect(buttonSize.height, greaterThanOrEqualTo(AppSizes.touchMin));
    });
  });
}

