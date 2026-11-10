import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/store_profile.dart';
import '../../domain/usecases/get_store_profile.dart';
import '../../domain/usecases/seed_sample_data.dart';
import '../../domain/usecases/update_store_profile.dart';
import 'store_profile_state.dart';

class StoreProfileCubit extends Cubit<StoreProfileState> {
  final GetStoreProfile getStoreProfileUseCase;
  final UpdateStoreProfile updateStoreProfileUseCase;
  final SeedSampleData seedSampleDataUseCase;

  StoreProfileCubit({
    required this.getStoreProfileUseCase,
    required this.updateStoreProfileUseCase,
    required this.seedSampleDataUseCase,
  }) : super(const StoreProfileState());

  Future<void> loadProfile() async {
    emit(state.copyWith(status: StoreProfileStatus.loading, clearError: true));
    try {
      final profile = await getStoreProfileUseCase();
      emit(
        state.copyWith(
          status: StoreProfileStatus.success,
          profile: profile,
          clearError: true,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: StoreProfileStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: StoreProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String address,
    required String phone,
    required String receiptFooter,
  }) async {
    emit(
      state.copyWith(
        status: StoreProfileStatus.loading,
        clearError: true,
        clearMessage: true,
      ),
    );
    try {
      final currentId = state.profile?.id ?? 1;
      final target = StoreProfile(
        id: currentId,
        name: name,
        address: address,
        phone: phone,
        receiptFooter: receiptFooter,
      );
      final updated = await updateStoreProfileUseCase(target);
      emit(
        state.copyWith(
          status: StoreProfileStatus.success,
          profile: updated,
          userMessage: AppStrings.storeProfileSaved,
          clearError: true,
        ),
      );
      return true;
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: StoreProfileStatus.failure,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      emit(
        state.copyWith(
          status: StoreProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  Future<bool> seedData() async {
    emit(
      state.copyWith(
        status: StoreProfileStatus.loading,
        clearError: true,
        clearMessage: true,
      ),
    );
    try {
      final seeded = await seedSampleDataUseCase();
      if (seeded) {
        emit(
          state.copyWith(
            status: StoreProfileStatus.success,
            userMessage: AppStrings.seedSampleDataSuccess,
            clearError: true,
          ),
        );
        return true;
      } else {
        emit(
          state.copyWith(
            status: StoreProfileStatus.failure,
            errorMessage: AppStrings.seedSampleDataAlreadyPopulated,
          ),
        );
        return false;
      }
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: StoreProfileStatus.failure,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      emit(
        state.copyWith(
          status: StoreProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearError: true, clearMessage: true));
  }
}

