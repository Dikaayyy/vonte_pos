import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';
import '../models/session_model.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getUserByUsername(String username);

  Future<UserModel> createUser({
    required String name,
    required String username,
    required String passwordHash,
    required String salt,
    required int createdAt,
  });

  Future<void> createSession({
    required int userId,
    required int loggedInAt,
  });

  Future<void> clearSession();

  Future<SessionModel?> getCurrentSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final AppDatabase _appDatabase;

  AuthLocalDataSourceImpl(this._appDatabase);

  Future<Database> get _db => _appDatabase.database;

  @override
  Future<UserModel?> getUserByUsername(String username) async {
    final db = await _db;
    final results = await db.query(
      AppTables.users,
      where: 'LOWER(username) = LOWER(?)',
      whereArgs: [username],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }
    return UserModel.fromMap(results.first);
  }

  @override
  Future<UserModel> createUser({
    required String name,
    required String username,
    required String passwordHash,
    required String salt,
    required int createdAt,
  }) async {
    final db = await _db;
    final id = await db.insert(
      AppTables.users,
      {
        'name': name,
        'username': username,
        'password_hash': passwordHash,
        'salt': salt,
        'created_at': createdAt,
      },
    );

    return UserModel(
      id: id,
      name: name,
      username: username,
      createdAt: createdAt,
      passwordHash: passwordHash,
      salt: salt,
    );
  }

  @override
  Future<void> createSession({
    required int userId,
    required int loggedInAt,
  }) async {
    final db = await _db;
    await db.transaction((txn) async {
      // Rule: at most one active session row in sessions table
      await txn.delete(AppTables.sessions);
      await txn.insert(
        AppTables.sessions,
        {
          'user_id': userId,
          'logged_in_at': loggedInAt,
        },
      );
    });
  }

  @override
  Future<void> clearSession() async {
    final db = await _db;
    await db.delete(AppTables.sessions);
  }

  @override
  Future<SessionModel?> getCurrentSession() async {
    final db = await _db;
    final results = await db.rawQuery(
      '''
      SELECT 
        s.id, 
        s.user_id, 
        s.logged_in_at, 
        u.name, 
        u.username, 
        u.created_at
      FROM ${AppTables.sessions} s
      INNER JOIN ${AppTables.users} u ON s.user_id = u.id
      ORDER BY s.id DESC
      LIMIT 1
      ''',
    );

    if (results.isEmpty) {
      return null;
    }
    return SessionModel.fromMap(results.first);
  }
}

