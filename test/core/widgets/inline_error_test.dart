import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/core/widgets/inline_error.dart';

void main() {
  group('InlineError', () {
    testWidgets('renders message and icon properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InlineError(
              message: 'Stok tidak cukup',
            ),
          ),
        ),
      );

      expect(find.text('Stok tidak cukup'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('renders empty widget when message is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InlineError(
              message: '   ',
            ),
          ),
        ),
      );

      expect(find.byType(Icon), findsNothing);
    });
  });
}

