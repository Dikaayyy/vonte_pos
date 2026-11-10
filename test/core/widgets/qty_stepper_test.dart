import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/core/widgets/qty_stepper.dart';

void main() {
  group('QtyStepper', () {
    testWidgets('increments and decrements value within range', (tester) async {
      int currentVal = 2;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return QtyStepper(
                  value: currentVal,
                  min: 1,
                  max: 5,
                  onChanged: (newVal) {
                    setState(() {
                      currentVal = newVal;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('2'), findsOneWidget);

      // Tap plus
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      expect(currentVal, 3);
      expect(find.text('3'), findsOneWidget);

      // Tap minus
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pumpAndSettle();
      expect(currentVal, 2);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('disables decrement button at min boundary', (tester) async {
      int currentVal = 1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QtyStepper(
              value: currentVal,
              min: 1,
              max: 5,
              onChanged: (val) {
                currentVal = val;
              },
            ),
          ),
        ),
      );

      final minusButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.remove_rounded),
      );
      expect(minusButton.onPressed, isNull);
    });

    testWidgets('disables increment at max boundary and shows disabledReason',
        (tester) async {
      const reason = 'Stok habis';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QtyStepper(
              value: 3,
              min: 1,
              max: 3,
              disabledReason: reason,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final plusButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.add_rounded),
      );
      expect(plusButton.onPressed, isNull);
      expect(find.text(reason), findsOneWidget);
    });
  });
}

