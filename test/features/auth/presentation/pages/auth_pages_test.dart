import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vonte_pos/core/constants/app_routes.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/core/theme/app_theme.dart';
import 'package:vonte_pos/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vonte_pos/features/auth/presentation/cubit/auth_state.dart';
import 'package:vonte_pos/features/auth/presentation/pages/login_page.dart';
import 'package:vonte_pos/features/auth/presentation/pages/register_page.dart';
import 'package:vonte_pos/features/auth/presentation/pages/splash_page.dart';

class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    when(() => mockAuthCubit.state).thenReturn(const AuthState());
    when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: BlocProvider<AuthCubit>.value(
        value: mockAuthCubit,
        child: child,
      ),
      routes: {
        AppRoutes.login: (_) => const Scaffold(body: Text('Login Screen')),
        AppRoutes.register: (_) => const Scaffold(body: Text('Register Screen')),
        AppRoutes.home: (_) => const Scaffold(body: Text('Home Screen')),
      },
    );
  }

  group('SplashPage', () {
    testWidgets('calls checkSession on startup and renders branding', (tester) async {
      when(() => mockAuthCubit.checkSession()).thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget(const SplashPage()));
      await tester.pump();

      verify(() => mockAuthCubit.checkSession()).called(1);
      expect(find.text(AppStrings.appName), findsOneWidget);
      expect(find.text(AppStrings.appTagline), findsOneWidget);
    });
  });

  group('LoginPage', () {
    testWidgets('renders input fields, title, and buttons', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage()));

      expect(find.text(AppStrings.authLoginTitle), findsOneWidget);
      expect(find.text(AppStrings.usernameLabel), findsOneWidget);
      expect(find.text(AppStrings.passwordLabel), findsOneWidget);
      expect(find.text(AppStrings.loginButton), findsOneWidget);
      expect(find.text(AppStrings.goToRegister), findsOneWidget);
    });

    testWidgets('shows validation errors when submitting empty form', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage()));

      await tester.tap(find.text(AppStrings.loginButton));
      await tester.pump();

      expect(find.text(AppStrings.usernameMinLength), findsOneWidget);
      expect(find.text(AppStrings.passwordMinLength), findsOneWidget);
      verifyNever(() => mockAuthCubit.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ));
    });

    testWidgets('calls cubit.login when valid credentials entered', (tester) async {
      when(
        () => mockAuthCubit.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget(const LoginPage()));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'kasir1');
      await tester.enterText(textFields.at(1), 'password123');

      await tester.tap(find.text(AppStrings.loginButton));
      await tester.pump();

      verify(
        () => mockAuthCubit.login(
          username: 'kasir1',
          password: 'password123',
        ),
      ).called(1);
    });

    testWidgets('displays server error message when state is failure', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(
        const AuthState(
          status: AuthStatus.failure,
          errorMessage: AppStrings.invalidCredentials,
        ),
      );

      await tester.pumpWidget(createTestWidget(const LoginPage()));

      expect(find.text(AppStrings.invalidCredentials), findsOneWidget);
    });
  });

  group('RegisterPage', () {
    testWidgets('renders name, username, password fields and register button', (tester) async {
      await tester.pumpWidget(createTestWidget(const RegisterPage()));

      expect(find.text(AppStrings.authRegisterTitle), findsOneWidget);
      expect(find.text(AppStrings.nameLabel), findsOneWidget);
      expect(find.text(AppStrings.usernameLabel), findsOneWidget);
      expect(find.text(AppStrings.passwordLabel), findsOneWidget);
      expect(find.text(AppStrings.registerButton), findsOneWidget);
    });

    testWidgets('validates required fields before calling cubit.register', (tester) async {
      await tester.pumpWidget(createTestWidget(const RegisterPage()));

      await tester.tap(find.text(AppStrings.registerButton));
      await tester.pump();

      expect(find.text(AppStrings.nameRequired), findsOneWidget);
      expect(find.text(AppStrings.usernameMinLength), findsOneWidget);
      expect(find.text(AppStrings.passwordMinLength), findsOneWidget);

      verifyNever(
        () => mockAuthCubit.register(
          name: any(named: 'name'),
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      );
    });
  });
}

