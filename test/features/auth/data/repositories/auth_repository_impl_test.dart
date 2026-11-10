import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/core/database/app_database.dart';
import 'package:vonte_pos/core/database/tables.dart';
import 'package:vonte_pos/core/error/exceptions.dart';
import 'package:vonte_pos/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:vonte_pos/features/auth/data/repositories/auth_repository_impl.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('AuthRepositoryImpl with In-Memory SQLite Database', () {
    late AppDatabase appDb;
    late Database db;
    late AuthLocalDataSource dataSource;
    late AuthRepositoryImpl repository;

    setUp(() async {
      appDb = AppDatabase.inMemory();
      db = await appDb.database;
      dataSource = AuthLocalDataSourceImpl(appDb);
      repository = AuthRepositoryImpl(dataSource);
    });

    tearDown(() async {
      await appDb.close();
    });

    test('register stores user and active session in database', () async {
      final user = await repository.register(
        name: 'Budi Kasir',
        username: 'budikasir',
        password: 'password123',
      );

      expect(user.id, greaterThan(0));
      expect(user.name, equals('Budi Kasir'));
      expect(user.username, equals('budikasir'));

      // Verify row in users table
      final userRows = await db.query(
        AppTables.users,
        where: 'id = ?',
        whereArgs: [user.id],
      );
      expect(userRows.length, equals(1));
      expect(userRows.first['username'], equals('budikasir'));
      expect(userRows.first['password_hash'], isNotNull);
      expect(userRows.first['salt'], isNotNull);

      // Verify row in sessions table
      final sessionRows = await db.query(AppTables.sessions);
      expect(sessionRows.length, equals(1));
      expect(sessionRows.first['user_id'], equals(user.id));
    });

    test('register throws AuthException when username is duplicate (case-insensitive)', () async {
      await repository.register(
        name: 'Kasir Satu',
        username: 'kasir_utama',
        password: 'password123',
      );

      // Attempt register with uppercase variant
      expect(
        () => repository.register(
          name: 'Kasir Dua',
          username: 'KASIR_UTAMA',
          password: 'password456',
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

    test('login succeeds with correct credentials (case-insensitive username)', () async {
      await repository.register(
        name: 'Siti Aminah',
        username: 'sitikasir',
        password: 'mypassword123',
      );

      // Login with different case: 'SitiKasir'
      final loggedInUser = await repository.login(
        username: 'SitiKasir',
        password: 'mypassword123',
      );

      expect(loggedInUser.username, equals('sitikasir'));
      expect(loggedInUser.name, equals('Siti Aminah'));

      final session = await repository.getCurrentSession();
      expect(session, isNotNull);
      expect(session!.userId, equals(loggedInUser.id));
      expect(session.user?.name, equals('Siti Aminah'));
    });

    test('login throws AuthException when password does not match', () async {
      await repository.register(
        name: 'Siti Aminah',
        username: 'sitikasir',
        password: 'mypassword123',
      );

      expect(
        () => repository.login(
          username: 'sitikasir',
          password: 'wrong_password',
        ),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            AppStrings.invalidCredentials,
          ),
        ),
      );
    });

    test('login throws AuthException when username does not exist', () async {
      expect(
        () => repository.login(
          username: 'non_existent_user',
          password: 'some_password',
        ),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            AppStrings.invalidCredentials,
          ),
        ),
      );
    });

    test('getCurrentSession returns null when no user is logged in', () async {
      final session = await repository.getCurrentSession();
      expect(session, isNull);
    });

    test('logout deletes active session row from database', () async {
      await repository.register(
        name: 'Test Logout',
        username: 'testlogout',
        password: 'password123',
      );

      final sessionBefore = await repository.getCurrentSession();
      expect(sessionBefore, isNotNull);

      await repository.logout();

      final sessionAfter = await repository.getCurrentSession();
      expect(sessionAfter, isNull);

      final sessionRows = await db.query(AppTables.sessions);
      expect(sessionRows.isEmpty, isTrue);
    });
  });
}

