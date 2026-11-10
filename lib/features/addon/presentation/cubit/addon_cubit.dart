import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/usecases/create_addon.dart';
import '../../domain/usecases/delete_addon.dart';
import '../../domain/usecases/get_addons.dart';
import '../../domain/usecases/update_addon.dart';
import 'addon_state.dart';

class AddonCubit extends Cubit<AddonState> {
  final GetAddons getAddonsUseCase;
  final CreateAddon createAddonUseCase;
  final UpdateAddon updateAddonUseCase;
  final DeleteAddon deleteAddonUseCase;

  AddonCubit({
    required this.getAddonsUseCase,
    required this.createAddonUseCase,
    required this.updateAddonUseCase,
    required this.deleteAddonUseCase,
  }) : super(const AddonState());

  Future<void> loadAddons() async {
    emit(state.copyWith(status: AddonStatus.loading, clearError: true));
    try {
      final addons = await getAddonsUseCase();
      emit(
        state.copyWith(
          status: AddonStatus.success,
          addons: addons,
          clearError: true,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: AddonStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AddonStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> addAddon({
    required String name,
    required int price,
    required int stock,
  }) async {
    emit(state.copyWith(status: AddonStatus.loading, clearError: true));
    try {
      await createAddonUseCase(name: name, price: price, stock: stock);
      final addons = await getAddonsUseCase();
      emit(
        state.copyWith(
          status: AddonStatus.success,
          addons: addons,
          clearError: true,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: AddonStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AddonStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> updateAddon({
    required int id,
    required String name,
    required int price,
    required int stock,
  }) async {
    emit(state.copyWith(status: AddonStatus.loading, clearError: true));
    try {
      await updateAddonUseCase(
        id: id,
        name: name,
        price: price,
        stock: stock,
      );
      final addons = await getAddonsUseCase();
      emit(
        state.copyWith(
          status: AddonStatus.success,
          addons: addons,
          clearError: true,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: AddonStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AddonStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> deleteAddon(int id) async {
    emit(state.copyWith(status: AddonStatus.loading, clearError: true));
    try {
      await deleteAddonUseCase(id);
      final addons = await getAddonsUseCase();
      emit(
        state.copyWith(
          status: AddonStatus.success,
          addons: addons,
          clearError: true,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: AddonStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AddonStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}

