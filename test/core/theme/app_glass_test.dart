import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/core/theme/app_glass.dart';

void main() {
  tearDown(() {
    AppGlass.disableBlur = false;
  });

  group('AppGlass', () {
    testWidgets('renders BackdropFilter when blur is enabled', (tester) async {
      AppGlass.disableBlur = false;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppGlass(
              child: Text('Glass Content'),
            ),
          ),
        ),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.text('Glass Content'), findsOneWidget);
    });

    testWidgets('falls back to solid DecoratedBox without BackdropFilter when disableBlur is true',
        (tester) async {
      AppGlass.disableBlur = true;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppGlass(
              child: Text('Solid Fallback Content'),
            ),
          ),
        ),
      );

      expect(find.byType(BackdropFilter), findsNothing);
      expect(find.text('Solid Fallback Content'), findsOneWidget);
    });

    testWidgets('falls back to solid when per-instance fallbackSolid is true',
        (tester) async {
      AppGlass.disableBlur = false;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppGlass(
              fallbackSolid: true,
              child: Text('Per-instance Solid'),
            ),
          ),
        ),
      );

      expect(find.byType(BackdropFilter), findsNothing);
      expect(find.text('Per-instance Solid'), findsOneWidget);
    });

    testWidgets('reacts dynamically to AppGlass.disableBlur state change',
        (tester) async {
      AppGlass.disableBlur = false;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppGlass(
              child: Text('Dynamic Test'),
            ),
          ),
        ),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);

      AppGlass.disableBlur = true;
      await tester.pumpAndSettle();

      expect(find.byType(BackdropFilter), findsNothing);
    });
  });
}

