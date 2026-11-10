import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/core/di/injection.dart';
import 'package:vonte_pos/core/theme/app_theme.dart';
import 'package:vonte_pos/features/category/domain/entities/category.dart';
import 'package:vonte_pos/features/category/presentation/cubit/category_cubit.dart';
import 'package:vonte_pos/features/category/presentation/cubit/category_state.dart';
import 'package:vonte_pos/features/category/presentation/pages/category_list_view.dart';
import 'package:vonte_pos/features/product/presentation/pages/product_shell_page.dart';

class MockCategoryCubit extends Mock implements CategoryCubit {}

void main() {
  late MockCategoryCubit mockCategoryCubit;

  const sampleCategories = [
    Category(id: 1, name: 'Minuman Kopi', productCount: 4),
    Category(id: 2, name: 'Camilan', productCount: 0),
  ];

  setUp(() {
    mockCategoryCubit = MockCategoryCubit();
    when(() => mockCategoryCubit.state).thenReturn(
      const CategoryState(
        status: CategoryStatus.success,
        categories: sampleCategories,
      ),
    );
    when(() => mockCategoryCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCategoryCubit.loadCategories()).thenAnswer((_) async {});
    when(() => mockCategoryCubit.close()).thenAnswer((_) async {});
  });

  Widget buildTestWidget({required Widget child}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: BlocProvider<CategoryCubit>.value(
          value: mockCategoryCubit,
          child: child,
        ),
      ),
    );
  }

  group('CategoryListView', () {
    testWidgets('renders category items with name and product count in tabular format', (tester) async {
      await tester.pumpWidget(buildTestWidget(child: const CategoryListView()));
      await tester.pumpAndSettle();

      expect(find.text('Minuman Kopi'), findsOneWidget);
      expect(find.text('4 produk'), findsOneWidget);

      expect(find.text('Camilan'), findsOneWidget);
      expect(find.text('0 produk'), findsOneWidget);

      expect(find.byKey(const Key('btn_edit_1')), findsOneWidget);
      expect(find.byKey(const Key('btn_delete_1')), findsOneWidget);
    });

    testWidgets('renders EmptyState when category list is empty', (tester) async {
      when(() => mockCategoryCubit.state).thenReturn(
        const CategoryState(
          status: CategoryStatus.success,
          categories: [],
        ),
      );

      await tester.pumpWidget(buildTestWidget(child: const CategoryListView()));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.emptyCategoryTitle), findsOneWidget);
      expect(find.text(AppStrings.emptyCategorySubtitle), findsOneWidget);
    });

    testWidgets('open add category dialog and validates empty input', (tester) async {
      await tester.pumpWidget(buildTestWidget(child: const CategoryListView()));
      await tester.pumpAndSettle();

      // Tap Tambah Kategori
      await tester.tap(find.text(AppStrings.addCategory).first);
      await tester.pumpAndSettle();

      // Dialog opens
      expect(find.text(AppStrings.categoryNameLabel), findsOneWidget);

      // Tap Simpan with empty field
      await tester.tap(find.text(AppStrings.save));
      await tester.pumpAndSettle();

      // Inline validation error displayed
      expect(find.text(AppStrings.categoryNameRequired), findsOneWidget);
    });

    testWidgets('hapus kategori displays confirmation dialog explaining products become Tanpa Kategori', (tester) async {
      when(() => mockCategoryCubit.deleteCategory(1)).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget(child: const CategoryListView()));
      await tester.pumpAndSettle();

      // Tap delete button on first category
      await tester.tap(find.byKey(const Key('btn_delete_1')));
      await tester.pumpAndSettle();

      // Verify confirmation dialog title and explanation text
      expect(find.text(AppStrings.deleteCategoryConfirmTitle), findsOneWidget);
      expect(find.text(AppStrings.deleteCategoryConfirmMessage), findsOneWidget);

      // Tap confirm Hapus button inside dialog
      await tester.tap(find.widgetWithText(ElevatedButton, AppStrings.delete));
      await tester.pumpAndSettle();

      verify(() => mockCategoryCubit.deleteCategory(1)).called(1);
    });
  });

  group('ProductShellPage (Segmented Control)', () {
    setUp(() async {
      if (getIt.isRegistered<CategoryCubit>()) {
        getIt.unregister<CategoryCubit>();
      }
      getIt.registerFactory<CategoryCubit>(() => mockCategoryCubit);
    });

    tearDown(() async {
      if (getIt.isRegistered<CategoryCubit>()) {
        getIt.unregister<CategoryCubit>();
      }
    });

    testWidgets('switches between Produk, Kategori, and Add-on segmented tabs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ProductShellPage(initialSubIndex: 1),
        ),
      );
      await tester.pumpAndSettle();

      // Initially on Kategori (index 1)
      expect(find.text(AppStrings.categoryListTitle), findsOneWidget);

      // Switch to Produk tab
      await tester.tap(find.byKey(const Key('segment_0')));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.productCatalogPlaceholder), findsOneWidget);

      // Switch to Add-on tab
      await tester.tap(find.byKey(const Key('segment_2')));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.addonCatalogPlaceholder), findsOneWidget);
    });
  });
}

