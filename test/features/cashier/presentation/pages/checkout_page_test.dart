import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/core/theme/app_theme.dart';
import 'package:vonte_pos/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vonte_pos/features/auth/presentation/cubit/auth_state.dart';
import 'package:vonte_pos/features/cashier/domain/entities/cart_line.dart';
import 'package:vonte_pos/features/cashier/presentation/cubit/cart_cubit.dart';
import 'package:vonte_pos/features/cashier/presentation/cubit/cart_state.dart';
import 'package:vonte_pos/features/cashier/presentation/cubit/checkout_cubit.dart';
import 'package:vonte_pos/features/cashier/presentation/pages/checkout_page.dart';
import 'package:vonte_pos/features/store_profile/presentation/cubit/store_profile_cubit.dart';
import 'package:vonte_pos/features/store_profile/presentation/cubit/store_profile_state.dart';
import 'package:vonte_pos/features/transaction/domain/entities/checkout_params.dart';
import 'package:vonte_pos/features/transaction/domain/entities/transaction.dart';
import 'package:vonte_pos/features/transaction/domain/usecases/checkout_use_case.dart';
import 'package:vonte_pos/core/error/result.dart';

class MockCheckoutUseCase extends Mock implements CheckoutUseCase {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockStoreProfileCubit extends MockCubit<StoreProfileState>
    implements StoreProfileCubit {}

class MockCartCubit extends MockCubit<CartState> implements CartCubit {}

void main() {
  late MockCheckoutUseCase mockCheckoutUseCase;
  late MockAuthCubit mockAuthCubit;
  late MockStoreProfileCubit mockStoreProfileCubit;
  late MockCartCubit mockCartCubit;
  late CheckoutCubit checkoutCubit;

  final sampleLines = [
    CartLine(
      productId: 1,
      productName: 'Kopi Susu Aren',
      unitPrice: 20000,
      qty: 2,
    ),
  ]; // subtotal = 40.000

  const sampleTransaction = Transaction(
    id: 1,
    invoiceNo: 'VNT-20261110-0001',
    cashierId: 1,
    cashierName: 'Kasir Utama',
    storeName: 'Vonte Coffee',
    storeAddress: 'Jl. Merdeka No. 1',
    storePhone: '081234567890',
    subtotal: 40000,
    discountType: 'none',
    discountValue: 0,
    discountAmount: 0,
    total: 40000,
    cashReceived: 40000,
    changeAmount: 0,
    createdAt: 1700000000000,
  );

  setUpAll(() {
    registerFallbackValue(
      const CheckoutParams(
        lines: [],
        cashReceived: 0,
        cashierId: 1,
        cashierName: 'Kasir',
      ),
    );
  });

  setUp(() {
    mockCheckoutUseCase = MockCheckoutUseCase();
    mockAuthCubit = MockAuthCubit();
    mockStoreProfileCubit = MockStoreProfileCubit();
    mockCartCubit = MockCartCubit();

    when(() => mockAuthCubit.state).thenReturn(const AuthState());
    when(() => mockStoreProfileCubit.state)
        .thenReturn(const StoreProfileState());
    when(() => mockCartCubit.state)
        .thenReturn(CartState(items: sampleLines));
    when(() => mockCartCubit.clearCart()).thenReturn(null);

    checkoutCubit = CheckoutCubit(checkoutUseCase: mockCheckoutUseCase);
  });

  tearDown(() {
    checkoutCubit.close();
  });

  Widget createWidget({CheckoutCubit? cubit}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: mockAuthCubit),
        BlocProvider<StoreProfileCubit>.value(value: mockStoreProfileCubit),
        BlocProvider<CartCubit>.value(value: mockCartCubit),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: CheckoutPage(
          checkoutCubit: cubit ?? checkoutCubit,
          cartCubit: mockCartCubit,
          initialLines: sampleLines,
        ),
      ),
    );
  }

  testWidgets('CheckoutPage renders summary block, discount, and cash sections',
      (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.checkoutTitle), findsOneWidget);
    expect(find.text(AppStrings.subtotal), findsOneWidget);
    expect(find.text('Rp40.000'), findsWidgets); // subtotal and total
    expect(find.text(AppStrings.discountLabel), findsOneWidget);
    expect(find.text(AppStrings.cashReceivedLabel), findsOneWidget);
    expect(find.text(AppStrings.discountTypeRp), findsOneWidget);
    expect(find.text(AppStrings.discountTypePercent), findsOneWidget);
  });

  testWidgets(
      'CheckoutPage initially disables Bayar button when cash is 0 and shows shortage warning',
      (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    // Shortage warning
    expect(find.textContaining(AppStrings.paymentShortage), findsOneWidget);

    // Pay button is disabled
    final payBtn = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );
    expect(payBtn.onPressed, isNull);
  });

  testWidgets(
      'Tapping "Uang pas" quick cash chip enables Bayar button and displays Kembalian Rp0',
      (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    // Find "Uang pas (Rp40.000)" chip
    final exactChip = find.text('Uang pas (Rp40.000)');
    expect(exactChip, findsOneWidget);

    await tester.tap(exactChip);
    await tester.pumpAndSettle();

    // Now change should show Rp0
    expect(find.textContaining('Kembalian: Rp0'), findsOneWidget);

    // Pay button should now be enabled
    final payBtn = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );
    expect(payBtn.onPressed, isNotNull);
  });

  testWidgets(
      'Inputting percent discount > 100 shows inline error and keeps button disabled',
      (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    // Switch to percent discount
    await tester.tap(find.text(AppStrings.discountTypePercent));
    await tester.pumpAndSettle();

    // Enter 110%
    final discountField = find.widgetWithText(TextFormField, '');
    await tester.enterText(discountField.first, '110');
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.discountPercentOutOfRange), findsOneWidget);

    // Pay button must stay disabled
    final payBtn = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );
    expect(payBtn.onPressed, isNull);
  });

  testWidgets(
      'Inputting fixed discount > subtotal shows inline error and keeps button disabled',
      (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    // Fixed is already default; enter 50000 (subtotal is 40000)
    final discountField = find.byType(TextFormField).first;
    await tester.enterText(discountField, '50000');
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.discountFixedExceedsSubtotal), findsOneWidget);

    final payBtn = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );
    expect(payBtn.onPressed, isNull);
  });

  testWidgets(
      'Successful payment calls clearCart and replaces route with ReceiptPage',
      (tester) async {
    when(() => mockCheckoutUseCase.call(any())).thenAnswer(
      (_) async => const Result.success(sampleTransaction),
    );

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    // Tap Uang Pas chip
    await tester.tap(find.text('Uang pas (Rp40.000)'));
    await tester.pumpAndSettle();

    // Tap Bayar
    final payBtnFinder = find.widgetWithText(ElevatedButton, 'Bayar Rp40.000');
    await tester.ensureVisible(payBtnFinder);
    await tester.pumpAndSettle();
    await tester.tap(payBtnFinder);
    await tester.pumpAndSettle();

    // Verify clearCart was called
    verify(() => mockCartCubit.clearCart()).called(1);

    // Receipt page rendered
    expect(find.text(AppStrings.receiptTitle), findsOneWidget);
    expect(find.text('VNT-20261110-0001'), findsOneWidget);
    expect(find.text(AppStrings.finishButton), findsOneWidget);
  });
}
