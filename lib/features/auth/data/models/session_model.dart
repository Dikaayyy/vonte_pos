import '../../domain/entities/session.dart';
import 'user_model.dart';

class SessionModel extends Session {
  const SessionModel({
    required super.id,
    required super.userId,
    required super.loggedInAt,
    super.user,
  });

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    UserModel? user;
    if (map.containsKey('name') && map['name'] != null) {
      user = UserModel(
        id: map['user_id'] as int,
        name: map['name'] as String,
        username: map['username'] as String,
        createdAt: (map['created_at'] as int?) ?? 0,
      );
    }

    return SessionModel(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      loggedInAt: map['logged_in_at'] as int,
      user: user,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'user_id': userId,
      'logged_in_at': loggedInAt,
    };
  }
}

