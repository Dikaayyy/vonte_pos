// TEMP: Test for DesignPreviewPage
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/core/theme/app_glass.dart';
import 'package:vonte_pos/features/design_preview/presentation/design_preview_page.dart';

void main() {
  tearDown(() {
    AppGlass.disableBlur = false;
  });

  group('DesignPreviewPage (TEMP)', () {
    testWidgets('renders all preview sections and toggles glass fallback switch',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DesignPreviewPage(),
        ),
      );
      // Pump one frame (not pumpAndSettle due to loading button's CircularProgressIndicator)
      await tester.pump(const Duration(milliseconds: 100));

      // Verify title is rendered
      expect(find.text('Pratinjau Sistem Desain'), findsOneWidget);

      // Verify BackdropFilter exists when blur is enabled
      expect(find.byType(BackdropFilter), findsWidgets);

      // Toggle fallback solid switch
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pump(const Duration(milliseconds: 100));

      expect(AppGlass.disableBlur, isTrue);
    });
  });
}
