import 'package:equatable/equatable.dart';

import '../../domain/entities/store_profile.dart';

enum StoreProfileStatus { initial, loading, success, failure }

class StoreProfileState extends Equatable {
  final StoreProfileStatus status;
  final StoreProfile? profile;
  final String? errorMessage;
  final String? userMessage;

  const StoreProfileState({
    this.status = StoreProfileStatus.initial,
    this.profile,
    this.errorMessage,
    this.userMessage,
  });

  StoreProfileState copyWith({
    StoreProfileStatus? status,
    StoreProfile? profile,
    String? errorMessage,
    String? userMessage,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return StoreProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      userMessage: clearMessage ? null : (userMessage ?? this.userMessage),
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage, userMessage];
}

