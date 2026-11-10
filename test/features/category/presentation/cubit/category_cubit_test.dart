import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/core/error/exceptions.dart';
import 'package:vonte_pos/features/category/domain/entities/category.dart';
import 'package:vonte_pos/features/category/domain/usecases/create_category.dart';
import 'package:vonte_pos/features/category/domain/usecases/delete_category.dart';
import 'package:vonte_pos/features/category/domain/usecases/get_categories.dart';
import 'package:vonte_pos/features/category/domain/usecases/update_category.dart';
import 'package:vonte_pos/features/category/presentation/cubit/category_cubit.dart';
import 'package:vonte_pos/features/category/presentation/cubit/category_state.dart';

class MockGetCategories extends Mock implements GetCategories {}

class MockCreateCategory extends Mock implements CreateCategory {}

class MockUpdateCategory extends Mock implements UpdateCategory {}

class MockDeleteCategory extends Mock implements DeleteCategory {}

void main() {
  late MockGetCategories mockGetCategories;
  late MockCreateCategory mockCreateCategory;
  late MockUpdateCategory mockUpdateCategory;
  late MockDeleteCategory mockDeleteCategory;

  const sampleCategories = [
    Category(id: 1, name: 'Minuman Kopi', productCount: 5),
    Category(id: 2, name: 'Makanan Ringan', productCount: 2),
  ];

  setUp(() {
    mockGetCategories = MockGetCategories();
    mockCreateCategory = MockCreateCategory();
    mockUpdateCategory = MockUpdateCategory();
    mockDeleteCategory = MockDeleteCategory();
  });

  CategoryCubit buildCubit() {
    return CategoryCubit(
      getCategoriesUseCase: mockGetCategories,
      createCategoryUseCase: mockCreateCategory,
      updateCategoryUseCase: mockUpdateCategory,
      deleteCategoryUseCase: mockDeleteCategory,
    );
  }

  group('CategoryCubit', () {
    test('initial state is correct', () {
      final cubit = buildCubit();
      expect(cubit.state, const CategoryState());
      expect(cubit.state.status, CategoryStatus.initial);
      expect(cubit.state.categories, isEmpty);
    });

    blocTest<CategoryCubit, CategoryState>(
      'loadCategories emits [loading, success] with fetched categories',
      build: () {
        when(() => mockGetCategories()).thenAnswer((_) async => sampleCategories);
        return buildCubit();
      },
      act: (cubit) => cubit.loadCategories(),
      expect: () => [
        const CategoryState(status: CategoryStatus.loading),
        const CategoryState(
          status: CategoryStatus.success,
          categories: sampleCategories,
        ),
      ],
      verify: (_) {
        verify(() => mockGetCategories()).called(1);
      },
    );

    blocTest<CategoryCubit, CategoryState>(
      'loadCategories emits [loading, failure] when error occurs',
      build: () {
        when(() => mockGetCategories()).thenThrow(
          const AppDatabaseException('Gagal memuat kategori.'),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.loadCategories(),
      expect: () => [
        const CategoryState(status: CategoryStatus.loading),
        const CategoryState(
          status: CategoryStatus.failure,
          errorMessage: 'Gagal memuat kategori.',
        ),
      ],
    );

    blocTest<CategoryCubit, CategoryState>(
      'addCategory calls use case, reloads categories, and emits [loading, success]',
      build: () {
        when(() => mockCreateCategory('Minuman')).thenAnswer(
          (_) async => const Category(id: 3, name: 'Minuman'),
        );
        when(() => mockGetCategories()).thenAnswer((_) async => [
          ...sampleCategories,
          const Category(id: 3, name: 'Minuman', productCount: 0),
        ]);
        return buildCubit();
      },
      act: (cubit) => cubit.addCategory('Minuman'),
      expect: () => [
        const CategoryState(status: CategoryStatus.loading),
        const CategoryState(
          status: CategoryStatus.success,
          categories: [
            ...sampleCategories,
            Category(id: 3, name: 'Minuman', productCount: 0),
          ],
        ),
      ],
      verify: (_) {
        verify(() => mockCreateCategory('Minuman')).called(1);
        verify(() => mockGetCategories()).called(1);
      },
    );

    blocTest<CategoryCubit, CategoryState>(
      'addCategory emits [loading, failure] when name is duplicate',
      build: () {
        when(() => mockCreateCategory('Minuman Kopi')).thenThrow(
          const ValidationException(AppStrings.categoryNameDuplicate),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.addCategory('Minuman Kopi'),
      expect: () => [
        const CategoryState(status: CategoryStatus.loading),
        const CategoryState(
          status: CategoryStatus.failure,
          errorMessage: AppStrings.categoryNameDuplicate,
        ),
      ],
    );

    blocTest<CategoryCubit, CategoryState>(
      'updateCategory calls use case, reloads categories, and emits [loading, success]',
      build: () {
        when(() => mockUpdateCategory(id: 1, name: 'Kopi Specialty')).thenAnswer(
          (_) async => const Category(id: 1, name: 'Kopi Specialty', productCount: 5),
        );
        when(() => mockGetCategories()).thenAnswer((_) async => [
          const Category(id: 1, name: 'Kopi Specialty', productCount: 5),
          sampleCategories[1],
        ]);
        return buildCubit();
      },
      act: (cubit) => cubit.updateCategory(1, 'Kopi Specialty'),
      expect: () => [
        const CategoryState(status: CategoryStatus.loading),
        CategoryState(
          status: CategoryStatus.success,
          categories: [
            const Category(id: 1, name: 'Kopi Specialty', productCount: 5),
            sampleCategories[1],
          ],
        ),
      ],
      verify: (_) {
        verify(() => mockUpdateCategory(id: 1, name: 'Kopi Specialty')).called(1);
        verify(() => mockGetCategories()).called(1);
      },
    );

    blocTest<CategoryCubit, CategoryState>(
      'deleteCategory calls use case, reloads categories, and emits [loading, success]',
      build: () {
        when(() => mockDeleteCategory(1)).thenAnswer((_) async {});
        when(() => mockGetCategories()).thenAnswer((_) async => [sampleCategories[1]]);
        return buildCubit();
      },
      act: (cubit) => cubit.deleteCategory(1),
      expect: () => [
        const CategoryState(status: CategoryStatus.loading),
        CategoryState(
          status: CategoryStatus.success,
          categories: [sampleCategories[1]],
        ),
      ],
      verify: (_) {
        verify(() => mockDeleteCategory(1)).called(1);
        verify(() => mockGetCategories()).called(1);
      },
    );

    test('clearError resets errorMessage in state', () {
      final cubit = buildCubit();
      cubit.emit(
        const CategoryState(
          status: CategoryStatus.failure,
          errorMessage: 'Sample error',
        ),
      );
      expect(cubit.state.errorMessage, 'Sample error');

      cubit.clearError();
      expect(cubit.state.errorMessage, isNull);
    });
  });
}

