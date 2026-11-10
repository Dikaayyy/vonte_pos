import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/update_category.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final GetCategories getCategoriesUseCase;
  final CreateCategory createCategoryUseCase;
  final UpdateCategory updateCategoryUseCase;
  final DeleteCategory deleteCategoryUseCase;

  CategoryCubit({
    required this.getCategoriesUseCase,
    required this.createCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
  }) : super(const CategoryState());

  Future<void> loadCategories() async {
    emit(state.copyWith(status: CategoryStatus.loading, clearError: true));
    try {
      final categories = await getCategoriesUseCase();
      emit(
        state.copyWith(
          status: CategoryStatus.success,
          categories: categories,
          clearError: true,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: CategoryStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoryStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> addCategory(String name) async {
    emit(state.copyWith(status: CategoryStatus.loading, clearError: true));
    try {
      await createCategoryUseCase(name);
      final categories = await getCategoriesUseCase();
      emit(
        state.copyWith(
          status: CategoryStatus.success,
          categories: categories,
          clearError: true,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: CategoryStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoryStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> updateCategory(int id, String name) async {
    emit(state.copyWith(status: CategoryStatus.loading, clearError: true));
    try {
      await updateCategoryUseCase(id: id, name: name);
      final categories = await getCategoriesUseCase();
      emit(
        state.copyWith(
          status: CategoryStatus.success,
          categories: categories,
          clearError: true,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: CategoryStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoryStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> deleteCategory(int id) async {
    emit(state.copyWith(status: CategoryStatus.loading, clearError: true));
    try {
      await deleteCategoryUseCase(id);
      final categories = await getCategoriesUseCase();
      emit(
        state.copyWith(
          status: CategoryStatus.success,
          categories: categories,
          clearError: true,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: CategoryStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoryStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}

