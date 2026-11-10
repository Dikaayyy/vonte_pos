import 'package:equatable/equatable.dart';

import 'user.dart';

class Session extends Equatable {
  final int id;
  final int userId;
  final int loggedInAt;
  final User? user;

  const Session({
    required this.id,
    required this.userId,
    required this.loggedInAt,
    this.user,
  });

  @override
  List<Object?> get props => [id, userId, loggedInAt, user];
}

