import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/core/error/exceptions.dart';
import 'package:vonte_pos/features/auth/domain/entities/session.dart';
import 'package:vonte_pos/features/auth/domain/entities/user.dart';
import 'package:vonte_pos/features/auth/domain/usecases/get_current_session.dart';
import 'package:vonte_pos/features/auth/domain/usecases/login_user.dart';
import 'package:vonte_pos/features/auth/domain/usecases/logout.dart';
import 'package:vonte_pos/features/auth/domain/usecases/register_user.dart';
import 'package:vonte_pos/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vonte_pos/features/auth/presentation/cubit/auth_state.dart';

class MockGetCurrentSession extends Mock implements GetCurrentSession {}

class MockLoginUser extends Mock implements LoginUser {}

class MockRegisterUser extends Mock implements RegisterUser {}

class MockLogout extends Mock implements Logout {}

void main() {
  late MockGetCurrentSession mockGetCurrentSession;
  late MockLoginUser mockLoginUser;
  late MockRegisterUser mockRegisterUser;
  late MockLogout mockLogout;

  const tUser = User(
    id: 1,
    name: 'Budi Santoso',
    username: 'budis',
    createdAt: 1700000000000,
  );

  const tSession = Session(
    id: 1,
    userId: 1,
    loggedInAt: 1700000000000,
    user: tUser,
  );

  setUp(() {
    mockGetCurrentSession = MockGetCurrentSession();
    mockLoginUser = MockLoginUser();
    mockRegisterUser = MockRegisterUser();
    mockLogout = MockLogout();
  });

  AuthCubit buildCubit() {
    return AuthCubit(
      getCurrentSessionUseCase: mockGetCurrentSession,
      loginUserUseCase: mockLoginUser,
      registerUserUseCase: mockRegisterUser,
      logoutUseCase: mockLogout,
    );
  }

  group('AuthCubit', () {
    test('initial state has AuthStatus.initial', () {
      final cubit = buildCubit();
      expect(
        cubit.state,
        equals(
          const AuthState(
            status: AuthStatus.initial,
            user: null,
            errorMessage: null,
          ),
        ),
      );
    });

    blocTest<AuthCubit, AuthState>(
      'checkSession emits [loading, authenticated] when active session with user exists',
      build: () {
        when(() => mockGetCurrentSession()).thenAnswer((_) async => tSession);
        return buildCubit();
      },
      act: (cubit) => cubit.checkSession(),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(status: AuthStatus.authenticated, user: tUser),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'checkSession emits [loading, unauthenticated] when no session exists',
      build: () {
        when(() => mockGetCurrentSession()).thenAnswer((_) async => null);
        return buildCubit();
      },
      act: (cubit) => cubit.checkSession(),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(status: AuthStatus.unauthenticated, user: null),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'login emits [loading, authenticated] on success',
      build: () {
        when(
          () => mockLoginUser(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => tUser);
        return buildCubit();
      },
      act: (cubit) => cubit.login(username: 'budis', password: 'password123'),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(status: AuthStatus.authenticated, user: tUser),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'login emits [loading, failure] when authentication fails',
      build: () {
        when(
          () => mockLoginUser(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const AuthException(AppStrings.invalidCredentials));
        return buildCubit();
      },
      act: (cubit) => cubit.login(username: 'budis', password: 'wrong_password'),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(
          status: AuthStatus.failure,
          errorMessage: AppStrings.invalidCredentials,
        ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'register emits [loading, authenticated] on success',
      build: () {
        when(
          () => mockRegisterUser(
            name: any(named: 'name'),
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => tUser);
        return buildCubit();
      },
      act: (cubit) => cubit.register(
        name: 'Budi Santoso',
        username: 'budis',
        password: 'password123',
      ),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(status: AuthStatus.authenticated, user: tUser),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'register emits [loading, failure] on validation or repo error',
      build: () {
        when(
          () => mockRegisterUser(
            name: any(named: 'name'),
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const AuthException(AppStrings.usernameAlreadyTaken));
        return buildCubit();
      },
      act: (cubit) => cubit.register(
        name: 'Budi Santoso',
        username: 'budis',
        password: 'password123',
      ),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(
          status: AuthStatus.failure,
          errorMessage: AppStrings.usernameAlreadyTaken,
        ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'logout emits [loading, unauthenticated] on success',
      build: () {
        when(() => mockLogout()).thenAnswer((_) async {});
        return buildCubit();
      },
      act: (cubit) => cubit.logout(),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(status: AuthStatus.unauthenticated, user: null),
      ],
    );

    test('clearError resets errorMessage to null while preserving status and user', () {
      final cubit = buildCubit();
      cubit.emit(
        const AuthState(
          status: AuthStatus.failure,
          errorMessage: 'Some error message',
          user: null,
        ),
      );

      cubit.clearError();

      expect(
        cubit.state,
        equals(
          const AuthState(
            status: AuthStatus.failure,
            errorMessage: null,
            user: null,
          ),
        ),
      );
    });
  });
}

