import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/core/theme/app_theme.dart';
import 'package:vonte_pos/features/auth/domain/entities/user.dart';
import 'package:vonte_pos/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vonte_pos/features/auth/presentation/cubit/auth_state.dart';
import 'package:vonte_pos/features/store_profile/domain/entities/store_profile.dart';
import 'package:vonte_pos/features/store_profile/presentation/cubit/store_profile_cubit.dart';
import 'package:vonte_pos/features/store_profile/presentation/cubit/store_profile_state.dart';
import 'package:vonte_pos/features/store_profile/presentation/pages/settings_page.dart';

class MockAuthCubit extends Mock implements AuthCubit {}

class MockStoreProfileCubit extends Mock implements StoreProfileCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;
  late MockStoreProfileCubit mockStoreProfileCubit;

  const testUser = User(
    id: 1,
    name: 'Siti Rahma',
    username: 'sitirahma',
    createdAt: 1700000000000,
  );

  const testProfile = StoreProfile(
    id: 1,
    name: 'Vonte Coffee & Toast',
    address: 'Jl. Surya Kencana No. 8',
    phone: '081234567890',
    receiptFooter: 'Semoga harimu menyenangkan!',
  );

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    mockStoreProfileCubit = MockStoreProfileCubit();

    when(() => mockAuthCubit.state).thenReturn(
      const AuthState(
        status: AuthStatus.authenticated,
        user: testUser,
      ),
    );
    when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockStoreProfileCubit.state).thenReturn(
      const StoreProfileState(
        status: StoreProfileStatus.success,
        profile: testProfile,
      ),
    );
    when(() => mockStoreProfileCubit.stream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockStoreProfileCubit.loadProfile()).thenAnswer((_) async {});
  });

  Widget buildWidget() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: BlocProvider<AuthCubit>.value(
        value: mockAuthCubit,
        child: SettingsPage(storeProfileCubit: mockStoreProfileCubit),
      ),
    );
  }

  void configureViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(500, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('SettingsPage Widget Tests', () {
    testWidgets('menampilkan informasi akun kasir dan status sesi',
        (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Siti Rahma'), findsOneWidget);
      expect(find.text('@sitirahma'), findsOneWidget);
      expect(find.text(AppStrings.activeSessionTitle), findsOneWidget);
      expect(find.text('#1'), findsOneWidget);
    });

    testWidgets('form profil toko terisi nilai awal dan memvalidasi input kosong',
        (tester) async {
      configureViewport(tester);
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Periksa nilai awal terisi di form
      expect(find.text('Vonte Coffee & Toast'), findsOneWidget);
      expect(find.text('Jl. Surya Kencana No. 8'), findsOneWidget);
      expect(find.text('081234567890'), findsOneWidget);
      expect(find.text('Semoga harimu menyenangkan!'), findsOneWidget);

      // Kosongkan nama toko dan coba simpan
      await tester.enterText(find.byKey(const Key('store_name_field')), '');
      final saveBtn = find.byKey(const Key('save_store_profile_button'));
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Validasi pesan error inline
      expect(find.text(AppStrings.storeNameRequired), findsOneWidget);
      verifyNever(() => mockStoreProfileCubit.updateProfile(
            name: any(named: 'name'),
            address: any(named: 'address'),
            phone: any(named: 'phone'),
            receiptFooter: any(named: 'receiptFooter'),
          ));
    });

    testWidgets('simpan profil memanggil updateProfile dengan nilai yang telah diedit',
        (tester) async {
      configureViewport(tester);
      when(() => mockStoreProfileCubit.updateProfile(
            name: any(named: 'name'),
            address: any(named: 'address'),
            phone: any(named: 'phone'),
            receiptFooter: any(named: 'receiptFooter'),
          )).thenAnswer((_) async => true);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Ubah nama toko
      await tester.enterText(
        find.byKey(const Key('store_name_field')),
        'Vonte Specialty Coffee',
      );
      final saveBtn = find.byKey(const Key('save_store_profile_button'));
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      verify(() => mockStoreProfileCubit.updateProfile(
            name: 'Vonte Specialty Coffee',
            address: 'Jl. Surya Kencana No. 8',
            phone: '081234567890',
            receiptFooter: 'Semoga harimu menyenangkan!',
          )).called(1);
    });

    testWidgets('tombol "Muat data contoh" membuka dialog konfirmasi dan memicu seedData saat dikonfirmasi',
        (tester) async {
      configureViewport(tester);
      when(() => mockStoreProfileCubit.seedData()).thenAnswer((_) async => true);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Scroll ke tombol Muat Data Contoh dan tap
      final seedBtn = find.byKey(const Key('seed_sample_data_button'));
      await tester.ensureVisible(seedBtn);
      await tester.tap(seedBtn);
      await tester.pumpAndSettle();

      // Dialog konfirmasi muncul
      expect(find.text(AppStrings.seedSampleDataConfirmTitle), findsOneWidget);
      expect(find.text(AppStrings.seedSampleDataConfirmMessage), findsOneWidget);

      // Konfirmasi muat data
      await tester.tap(find.widgetWithText(ElevatedButton, AppStrings.confirmSeed));
      await tester.pumpAndSettle();

      verify(() => mockStoreProfileCubit.seedData()).called(1);
    });

    testWidgets('tombol "Keluar" membuka dialog konfirmasi dan memicu logout saat dikonfirmasi',
        (tester) async {
      configureViewport(tester);
      when(() => mockAuthCubit.logout()).thenAnswer((_) async {});

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Tap Keluar
      final logoutBtn = find.widgetWithText(ElevatedButton, AppStrings.logout);
      await tester.ensureVisible(logoutBtn);
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      // Dialog konfirmasi logout muncul
      expect(find.text(AppStrings.logoutConfirmTitle), findsOneWidget);
      expect(find.text(AppStrings.logoutConfirmMessage), findsOneWidget);

      // Konfirmasi keluar di dialog
      final confirmBtn = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(ElevatedButton, AppStrings.logout),
      );
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      verify(() => mockAuthCubit.logout()).called(1);
    });
  });
}
