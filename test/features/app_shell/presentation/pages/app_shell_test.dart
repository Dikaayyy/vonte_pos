import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vonte_pos/core/constants/app_routes.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/core/theme/app_colors.dart';
import 'package:vonte_pos/core/theme/app_theme.dart';
import 'package:vonte_pos/features/app_shell/presentation/pages/app_shell_page.dart';
import 'package:vonte_pos/features/app_shell/presentation/widgets/floating_glass_bottom_bar.dart';
import 'package:vonte_pos/features/auth/domain/entities/user.dart';
import 'package:vonte_pos/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vonte_pos/features/auth/presentation/cubit/auth_state.dart';

class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;

  const testUser = User(
    id: 1,
    name: 'Budi Kasir',
    username: 'budi',
    createdAt: 1700000000000,
  );

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    when(() => mockAuthCubit.state).thenReturn(
      const AuthState(
        status: AuthStatus.authenticated,
        user: testUser,
      ),
    );
    when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildTestWidget({
    required Widget child,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: BlocProvider<AuthCubit>.value(
        value: mockAuthCubit,
        child: child,
      ),
      routes: {
        AppRoutes.login: (_) => const Scaffold(body: Text('Login Page')),
      },
    );
  }

  group('AppShell Responsive Breakpoints (LayoutBuilder)', () {
    testWidgets('pada lebar 400dp muncul bottom bar dan tidak muncul rail',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(child: const AppShell()));
      await tester.pumpAndSettle();

      // Compact: floating glass bottom bar exists, navigation rail does not
      expect(find.byType(FloatingGlassBottomBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);

      // Ensures no center FAB exists as required by DESIGN.md
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('pada lebar 700dp (medium) tetap muncul bottom bar dan tidak muncul rail',
        (tester) async {
      tester.view.physicalSize = const Size(700, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(child: const AppShell()));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingGlassBottomBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('pada lebar 900dp (expanded >= 840dp) muncul rail dan tidak muncul bottom bar',
        (tester) async {
      tester.view.physicalSize = const Size(900, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(child: const AppShell()));
      await tester.pumpAndSettle();

      // Expanded: navigation rail exists on the left, floating bottom bar does not
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(FloatingGlassBottomBar), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });

  group('AppShell Navigation & State Persistence (IndexedStack)', () {
    testWidgets('Tab Kasir adalah tab pertama dan halaman utama default',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(child: const AppShell()));
      await tester.pumpAndSettle();

      // Kasir placeholder is active
      expect(find.text(AppStrings.cashierPlaceholderSubtitle), findsWidgets);
      expect(find.byKey(const Key('cashier_counter_text')), findsOneWidget);
      expect(find.text('0 pesanan'), findsOneWidget);
    });

    testWidgets('Item aktif memakai ikon terisi dan primary, item tidak aktif memakai ikon outline',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(child: const AppShell()));
      await tester.pumpAndSettle();

      // When tab Kasir (index 0) is active:
      // Active Kasir icon should be filled: Icons.point_of_sale_rounded
      // Inactive icons should be outline: Icons.inventory_2_outlined, Icons.bar_chart_outlined, Icons.settings_outlined
      final cashierIcon = tester.widget<Icon>(
        find.descendant(
          of: find.byType(FloatingGlassBottomBar),
          matching: find.byIcon(Icons.point_of_sale_rounded),
        ),
      );
      expect(cashierIcon.color, AppColors.primary);

      final productIcon = tester.widget<Icon>(
        find.descendant(
          of: find.byType(FloatingGlassBottomBar),
          matching: find.byIcon(Icons.inventory_2_outlined),
        ),
      );
      expect(productIcon.color, AppColors.onSurfaceVariant);

      final reportIcon = tester.widget<Icon>(
        find.descendant(
          of: find.byType(FloatingGlassBottomBar),
          matching: find.byIcon(Icons.bar_chart_outlined),
        ),
      );
      expect(reportIcon.color, AppColors.onSurfaceVariant);

      final settingsIcon = tester.widget<Icon>(
        find.descendant(
          of: find.byType(FloatingGlassBottomBar),
          matching: find.byIcon(Icons.settings_outlined),
        ),
      );
      expect(settingsIcon.color, AppColors.onSurfaceVariant);
    });

    testWidgets('Navigasi antar tab tidak membuat ulang state tab lain (IndexedStack)',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(child: const AppShell()));
      await tester.pumpAndSettle();

      // 1. In Kasir tab, mutate state: increment order counter
      expect(find.text('0 pesanan'), findsOneWidget);
      await tester.tap(find.text('Tambah Antrean'));
      await tester.pump();
      expect(find.text('1 pesanan'), findsOneWidget);

      // 2. Switch to Produk tab
      await tester.tap(find.text(AppStrings.navProduct));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.productPlaceholderSubtitle), findsWidgets);

      // 3. Switch back to Kasir tab
      await tester.tap(find.text(AppStrings.navCashier));
      await tester.pumpAndSettle();

      // 4. Assert counter state was preserved (still '1 pesanan', not reset to 0)
      expect(find.text('1 pesanan'), findsOneWidget);
    });

    testWidgets('Tab Pengaturan menampilkan info kasir dan dialog logout berfungsi',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => mockAuthCubit.logout()).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget(child: const AppShell()));
      await tester.pumpAndSettle();

      // Switch to Pengaturan tab
      await tester.tap(find.text(AppStrings.navSettings));
      await tester.pumpAndSettle();

      // Verify user info is visible
      expect(find.text('Budi Kasir'), findsOneWidget);
      expect(find.text('@budi'), findsOneWidget);
      expect(find.text(AppStrings.activeSessionTitle), findsOneWidget);

      // Tap Logout button
      await tester.tap(find.widgetWithText(ElevatedButton, AppStrings.logout));
      await tester.pumpAndSettle();

      // Confirm dialog appears
      expect(find.text('Konfirmasi Keluar'), findsOneWidget);

      // Tap confirm in dialog
      final confirmLogoutBtn = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(ElevatedButton, AppStrings.logout),
      );
      await tester.tap(confirmLogoutBtn);
      await tester.pumpAndSettle();

      verify(() => mockAuthCubit.logout()).called(1);
    });
  });
}
