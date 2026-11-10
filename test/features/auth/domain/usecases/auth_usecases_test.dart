import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/core/error/exceptions.dart';
import 'package:vonte_pos/features/auth/domain/entities/session.dart';
import 'package:vonte_pos/features/auth/domain/entities/user.dart';
import 'package:vonte_pos/features/auth/domain/repositories/auth_repository.dart';
import 'package:vonte_pos/features/auth/domain/usecases/get_current_session.dart';
import 'package:vonte_pos/features/auth/domain/usecases/login_user.dart';
import 'package:vonte_pos/features/auth/domain/usecases/logout.dart';
import 'package:vonte_pos/features/auth/domain/usecases/register_user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late RegisterUser registerUser;
  late LoginUser loginUser;
  late Logout logout;
  late GetCurrentSession getCurrentSession;

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
    mockRepository = MockAuthRepository();
    registerUser = RegisterUser(mockRepository);
    loginUser = LoginUser(mockRepository);
    logout = Logout(mockRepository);
    getCurrentSession = GetCurrentSession(mockRepository);
  });

  group('RegisterUser UseCase', () {
    test('throws ValidationException when name is invalid without calling repo', () async {
      expect(
        () => registerUser(name: '', username: 'kasir1', password: 'password123'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            AppStrings.nameRequired,
          ),
        ),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('throws ValidationException when username has space without calling repo', () async {
      expect(
        () => registerUser(
          name: 'Budi',
          username: 'kasir utama',
          password: 'password123',
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            AppStrings.usernameNoSpaces,
          ),
        ),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('throws ValidationException when password is too short without calling repo', () async {
      expect(
        () => registerUser(name: 'Budi', username: 'kasir1', password: '123'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            AppStrings.passwordMinLength,
          ),
        ),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('calls repository.register and returns User on valid input', () async {
      when(
        () => mockRepository.register(
          name: any(named: 'name'),
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => tUser);

      final result = await registerUser(
        name: '  Budi Santoso  ',
        username: 'budis',
        password: 'password123',
      );

      expect(result, equals(tUser));
      verify(
        () => mockRepository.register(
          name: 'Budi Santoso',
          username: 'budis',
          password: 'password123',
        ),
      ).called(1);
    });

    test('bubbles up AuthException from repository when username is already taken', () async {
      when(
        () => mockRepository.register(
          name: any(named: 'name'),
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthException(AppStrings.usernameAlreadyTaken));

      expect(
        () => registerUser(
          name: 'Budi Santoso',
          username: 'budis',
          password: 'password123',
        ),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            AppStrings.usernameAlreadyTaken,
          ),
        ),
      );
    });
  });

  group('LoginUser UseCase', () {
    test('throws ValidationException on short username without calling repo', () async {
      expect(
        () => loginUser(username: 'ab', password: 'password123'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            AppStrings.usernameMinLength,
          ),
        ),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('throws ValidationException on short password without calling repo', () async {
      expect(
        () => loginUser(username: 'kasir1', password: '123'),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            AppStrings.passwordMinLength,
          ),
        ),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('calls repository.login and returns User on valid input', () async {
      when(
        () => mockRepository.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => tUser);

      final result = await loginUser(
        username: 'budis',
        password: 'password123',
      );

      expect(result, equals(tUser));
      verify(
        () => mockRepository.login(
          username: 'budis',
          password: 'password123',
        ),
      ).called(1);
    });

    test('bubbles up AuthException from repository on invalid credentials', () async {
      when(
        () => mockRepository.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthException(AppStrings.invalidCredentials));

      expect(
        () => loginUser(username: 'budis', password: 'wrong_password'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            AppStrings.invalidCredentials,
          ),
        ),
      );
    });
  });

  group('Logout UseCase', () {
    test('calls repository.logout()', () async {
      when(() => mockRepository.logout()).thenAnswer((_) async {});

      await logout();

      verify(() => mockRepository.logout()).called(1);
    });
  });

  group('GetCurrentSession UseCase', () {
    test('returns Session from repository', () async {
      when(() => mockRepository.getCurrentSession()).thenAnswer((_) async => tSession);

      final result = await getCurrentSession();

      expect(result, equals(tSession));
      verify(() => mockRepository.getCurrentSession()).called(1);
    });

    test('returns null when no active session exists in repository', () async {
      when(() => mockRepository.getCurrentSession()).thenAnswer((_) async => null);

      final result = await getCurrentSession();

      expect(result, isNull);
      verify(() => mockRepository.getCurrentSession()).called(1);
    });
  });
}

