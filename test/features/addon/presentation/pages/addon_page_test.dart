import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vonte_pos/core/constants/app_constants.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/core/theme/app_theme.dart';
import 'package:vonte_pos/features/addon/domain/entities/addon.dart';
import 'package:vonte_pos/features/addon/presentation/cubit/addon_cubit.dart';
import 'package:vonte_pos/features/addon/presentation/cubit/addon_state.dart';
import 'package:vonte_pos/features/addon/presentation/pages/addon_list_view.dart';
import 'package:vonte_pos/features/product/presentation/pages/product_shell_page.dart';

class MockAddonCubit extends Mock implements AddonCubit {}

void main() {
  late MockAddonCubit mockAddonCubit;

  final sampleAddons = [
    const Addon(id: 1, name: 'Extra Shot Espresso', price: 4000, stock: 15),
    const Addon(
      id: 2,
      name: 'Caramel Syrup',
      price: 3000,
      stock: AppConstants.lowStockThreshold, // 5 -> isLowStock
    ),
    const Addon(id: 3, name: 'Oat Milk Sub', price: 0, stock: 0), // 0 -> outOfStock, price 0 -> Gratis
  ];

  setUp(() {
    mockAddonCubit = MockAddonCubit();
    when(() => mockAddonCubit.state).thenReturn(
      AddonState(
        status: AddonStatus.success,
        addons: sampleAddons,
      ),
    );
    when(() => mockAddonCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAddonCubit.loadAddons()).thenAnswer((_) async {});
    when(() => mockAddonCubit.close()).thenAnswer((_) async {});
  });

  Widget buildTestWidget({required Widget child}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: BlocProvider<AddonCubit>.value(
          value: mockAddonCubit,
          child: child,
        ),
      ),
    );
  }

  group('AddonListView', () {
    testWidgets(
        'renders addon items with price, stock, and low stock/out of stock badges',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(child: const AddonListView()));
      await tester.pumpAndSettle();

      // Normal item
      expect(find.text('Extra Shot Espresso'), findsOneWidget);
      expect(find.text('Rp4.000'), findsOneWidget);
      expect(find.text('${AppStrings.stockLabelPrefix} 15'), findsOneWidget);

      // Low stock item (stock = 5 <= threshold)
      expect(find.text('Caramel Syrup'), findsOneWidget);
      expect(find.text('Rp3.000'), findsOneWidget);
      expect(find.text('Sisa 5'), findsOneWidget);

      // Out of stock & free item (price = 0, stock = 0)
      expect(find.text('Oat Milk Sub'), findsOneWidget);
      expect(find.text(AppStrings.freePriceLabel), findsOneWidget);
      expect(find.text(AppStrings.outOfStockBadge), findsOneWidget);

      // Buttons
      expect(find.byKey(const Key('edit_addon_1')), findsOneWidget);
      expect(find.byKey(const Key('delete_addon_1')), findsOneWidget);
    });

    testWidgets('renders EmptyState when addon list is empty', (tester) async {
      when(() => mockAddonCubit.state).thenReturn(
        const AddonState(
          status: AddonStatus.success,
          addons: [],
        ),
      );

      await tester.pumpWidget(buildTestWidget(child: const AddonListView()));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.emptyAddonTitle), findsOneWidget);
      expect(find.text(AppStrings.emptyAddonSubtitle), findsOneWidget);
    });

    testWidgets('open add addon dialog and validates invalid inputs',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(child: const AddonListView()));
      await tester.pumpAndSettle();

      // Tap Tambah Add-on
      await tester.tap(find.widgetWithText(ElevatedButton, AppStrings.addAddon).first);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.addAddon), findsWidgets);

      // Clear the default name field (already empty) and submit
      await tester.tap(find.widgetWithText(ElevatedButton, AppStrings.save));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.addonNameRequired), findsOneWidget);
    });

    testWidgets(
        'open delete addon dialog and displays soft delete confirmation message',
        (tester) async {
      when(() => mockAddonCubit.deleteAddon(1)).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget(child: const AddonListView()));
      await tester.pumpAndSettle();

      // Tap delete on addon 1
      await tester.tap(find.byKey(const Key('delete_addon_1')));
      await tester.pumpAndSettle();

      // Confirmation dialog is displayed
      expect(find.text(AppStrings.deleteAddonConfirmTitle), findsOneWidget);
      expect(find.text(AppStrings.deleteAddonConfirmMessage), findsOneWidget);

      // Tap confirm Hapus button inside dialog
      await tester.tap(find.widgetWithText(ElevatedButton, AppStrings.delete));
      await tester.pumpAndSettle();

      verify(() => mockAddonCubit.deleteAddon(1)).called(1);
    });

    testWidgets('ProductShellPage renders AddonListView when addonCubit is provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ProductShellPage(
            initialSubIndex: 2, // Add-on tab
            addonCubit: mockAddonCubit,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.addonListTitle), findsOneWidget);
      expect(find.text('Extra Shot Espresso'), findsOneWidget);
    });
  });
}

