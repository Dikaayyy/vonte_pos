import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vonte_pos/core/constants/app_constants.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/core/widgets/stock_badge.dart';
import 'package:vonte_pos/features/addon/domain/entities/addon.dart';
import 'package:vonte_pos/features/addon/presentation/cubit/addon_cubit.dart';
import 'package:vonte_pos/features/addon/presentation/cubit/addon_state.dart';
import 'package:vonte_pos/features/addon/presentation/pages/addon_list_view.dart';

class MockAddonCubit extends MockCubit<AddonState> implements AddonCubit {}

void main() {
  late MockAddonCubit mockAddonCubit;

  setUp(() {
    mockAddonCubit = MockAddonCubit();
  });

  Widget buildTestWidget({required List<Addon> addons}) {
    when(() => mockAddonCubit.state).thenReturn(
      AddonState(
        status: AddonStatus.success,
        addons: addons,
      ),
    );

    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: BlocProvider<AddonCubit>.value(
            value: mockAddonCubit,
            child: const AddonListView(),
          ),
        ),
      ),
    );
  }

  group('AddonListView Stock Threshold & Consistency Tests', () {
    testWidgets(
        'tepat di ambang (stock == 5): shows "Sisa 5" badge and NO redundant "Stok: 5"',
        (tester) async {
      const addon = Addon(
        id: 1,
        name: 'Caramel Syrup',
        price: 3000,
        stock: AppConstants.lowStockThreshold,
      );

      await tester.pumpWidget(buildTestWidget(addons: [addon]));
      await tester.pumpAndSettle();

      // Renders StockBadge with 'Sisa 5'
      expect(find.byType(StockBadge), findsOneWidget);
      expect(find.text('${AppStrings.lowStockPrefix} 5'), findsOneWidget);

      // Redundant 'Stok: 5' is NOT rendered
      expect(find.text('${AppStrings.stockLabelPrefix} 5'), findsNothing);
    });

    testWidgets(
        'di atas ambang (stock == 6): NO low stock badge, shows normal "Stok: 6"',
        (tester) async {
      const addon = Addon(
        id: 1,
        name: 'Hazelnut Syrup',
        price: 3000,
        stock: AppConstants.lowStockThreshold + 1,
      );

      await tester.pumpWidget(buildTestWidget(addons: [addon]));
      await tester.pumpAndSettle();

      // No low stock badge
      expect(find.textContaining(AppStrings.lowStockPrefix), findsNothing);

      // Normal stock text should be displayed
      expect(find.text('${AppStrings.stockLabelPrefix} 6'), findsOneWidget);
    });

    testWidgets(
        'stok 0: shows "Habis" badge and NO redundant "Stok: 0"',
        (tester) async {
      const addon = Addon(
        id: 1,
        name: 'Vanilla Syrup',
        price: 3000,
        stock: 0,
      );

      await tester.pumpWidget(buildTestWidget(addons: [addon]));
      await tester.pumpAndSettle();

      // Shows 'Habis' badge
      expect(find.text(AppStrings.outOfStockBadge), findsOneWidget);

      // Redundant 'Stok: 0' is NOT rendered
      expect(find.text('${AppStrings.stockLabelPrefix} 0'), findsNothing);
    });
  });
}

