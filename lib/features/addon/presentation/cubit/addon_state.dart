import 'package:equatable/equatable.dart';

import '../../domain/entities/addon.dart';

enum AddonStatus { initial, loading, success, failure }

class AddonState extends Equatable {
  final AddonStatus status;
  final List<Addon> addons;
  final String? errorMessage;

  const AddonState({
    this.status = AddonStatus.initial,
    this.addons = const [],
    this.errorMessage,
  });

  AddonState copyWith({
    AddonStatus? status,
    List<Addon>? addons,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddonState(
      status: status ?? this.status,
      addons: addons ?? this.addons,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, addons, errorMessage];
}

