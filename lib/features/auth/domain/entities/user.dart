import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String username;
  final int createdAt;

  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, username, createdAt];
}

