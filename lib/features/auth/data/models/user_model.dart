import '../../domain/entities/user.dart';

class UserModel extends User {
  final String? passwordHash;
  final String? salt;

  const UserModel({
    required super.id,
    required super.name,
    required super.username,
    required super.createdAt,
    this.passwordHash,
    this.salt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int,
      name: map['name'] as String,
      username: map['username'] as String,
      createdAt: map['created_at'] as int,
      passwordHash: map['password_hash'] as String?,
      salt: map['salt'] as String?,
    );
  }

  Map<String, dynamic> toMap({
    required String passwordHash,
    required String salt,
  }) {
    return {
      if (id > 0) 'id': id,
      'name': name,
      'username': username,
      'password_hash': passwordHash,
      'salt': salt,
      'created_at': createdAt,
    };
  }
}

