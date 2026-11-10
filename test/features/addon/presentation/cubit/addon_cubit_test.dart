import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vonte_pos/core/error/exceptions.dart';
import 'package:vonte_pos/features/addon/domain/entities/addon.dart';
import 'package:vonte_pos/features/addon/domain/usecases/create_addon.dart';
import 'package:vonte_pos/features/addon/domain/usecases/delete_addon.dart';
import 'package:vonte_pos/features/addon/domain/usecases/get_addons.dart';
import 'package:vonte_pos/features/addon/domain/usecases/update_addon.dart';
import 'package:vonte_pos/features/addon/presentation/cubit/addon_cubit.dart';
import 'package:vonte_pos/features/addon/presentation/cubit/addon_state.dart';

class MockGetAddons extends Mock implements GetAddons {}

class MockCreateAddon extends Mock implements CreateAddon {}

class MockUpdateAddon extends Mock implements UpdateAddon {}

class MockDeleteAddon extends Mock implements DeleteAddon {}

void main() {
  late MockGetAddons mockGetAddons;
  late MockCreateAddon mockCreateAddon;
  late MockUpdateAddon mockUpdateAddon;
  late MockDeleteAddon mockDeleteAddon;

  const sampleAddons = [
    Addon(id: 1, name: 'Extra Shot', price: 4000, stock: 10),
    Addon(id: 2, name: 'Caramel Syrup', price: 3000, stock: 2),
  ];

  setUp(() {
    mockGetAddons = MockGetAddons();
    mockCreateAddon = MockCreateAddon();
    mockUpdateAddon = MockUpdateAddon();
    mockDeleteAddon = MockDeleteAddon();
  });

  AddonCubit buildCubit() {
    return AddonCubit(
      getAddonsUseCase: mockGetAddons,
      createAddonUseCase: mockCreateAddon,
      updateAddonUseCase: mockUpdateAddon,
      deleteAddonUseCase: mockDeleteAddon,
    );
  }

  group('AddonCubit', () {
    test('initial state is correct', () {
      final cubit = buildCubit();
      expect(cubit.state, const AddonState());
      expect(cubit.state.status, AddonStatus.initial);
      expect(cubit.state.addons, isEmpty);
      expect(cubit.state.errorMessage, isNull);
    });

    blocTest<AddonCubit, AddonState>(
      'loadAddons emits [loading, success] with fetched addons',
      build: () {
        when(() => mockGetAddons()).thenAnswer((_) async => sampleAddons);
        return buildCubit();
      },
      act: (cubit) => cubit.loadAddons(),
      expect: () => [
        const AddonState(status: AddonStatus.loading),
        const AddonState(
          status: AddonStatus.success,
          addons: sampleAddons,
        ),
      ],
      verify: (_) {
        verify(() => mockGetAddons()).called(1);
      },
    );

    blocTest<AddonCubit, AddonState>(
      'loadAddons emits [loading, failure] when error occurs',
      build: () {
        when(() => mockGetAddons()).thenThrow(
          const AppDatabaseException('Gagal memuat add-on.'),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.loadAddons(),
      expect: () => [
        const AddonState(status: AddonStatus.loading),
        const AddonState(
          status: AddonStatus.failure,
          errorMessage: 'Gagal memuat add-on.',
        ),
      ],
    );

    blocTest<AddonCubit, AddonState>(
      'addAddon calls create use case, reloads addons, and emits [loading, success]',
      build: () {
        when(() => mockCreateAddon(name: 'Hazelnut', price: 5000, stock: 8))
            .thenAnswer(
          (_) async => const Addon(id: 3, name: 'Hazelnut', price: 5000, stock: 8),
        );
        when(() => mockGetAddons()).thenAnswer((_) async => [
              ...sampleAddons,
              const Addon(id: 3, name: 'Hazelnut', price: 5000, stock: 8),
            ]);
        return buildCubit();
      },
      act: (cubit) => cubit.addAddon(name: 'Hazelnut', price: 5000, stock: 8),
      expect: () => [
        const AddonState(status: AddonStatus.loading),
        const AddonState(
          status: AddonStatus.success,
          addons: [
            ...sampleAddons,
            Addon(id: 3, name: 'Hazelnut', price: 5000, stock: 8),
          ],
        ),
      ],
      verify: (_) {
        verify(() => mockCreateAddon(name: 'Hazelnut', price: 5000, stock: 8))
            .called(1);
        verify(() => mockGetAddons()).called(1);
      },
    );

    blocTest<AddonCubit, AddonState>(
      'addAddon emits [loading, failure] when create use case throws ValidationException',
      build: () {
        when(() => mockCreateAddon(name: '', price: -100, stock: -1))
            .thenThrow(const ValidationException('Input tidak valid.'));
        return buildCubit();
      },
      act: (cubit) => cubit.addAddon(name: '', price: -100, stock: -1),
      expect: () => [
        const AddonState(status: AddonStatus.loading),
        const AddonState(
          status: AddonStatus.failure,
          errorMessage: 'Input tidak valid.',
        ),
      ],
    );

    blocTest<AddonCubit, AddonState>(
      'updateAddon calls update use case, reloads addons, and emits [loading, success]',
      build: () {
        when(() => mockUpdateAddon(
              id: 1,
              name: 'Extra Shot Espresso',
              price: 4500,
              stock: 12,
            )).thenAnswer(
          (_) async => const Addon(
            id: 1,
            name: 'Extra Shot Espresso',
            price: 4500,
            stock: 12,
          ),
        );
        when(() => mockGetAddons()).thenAnswer((_) async => [
              const Addon(
                id: 1,
                name: 'Extra Shot Espresso',
                price: 4500,
                stock: 12,
              ),
              sampleAddons[1],
            ]);
        return buildCubit();
      },
      act: (cubit) => cubit.updateAddon(
        id: 1,
        name: 'Extra Shot Espresso',
        price: 4500,
        stock: 12,
      ),
      expect: () => [
        const AddonState(status: AddonStatus.loading),
        AddonState(
          status: AddonStatus.success,
          addons: [
            const Addon(
              id: 1,
              name: 'Extra Shot Espresso',
              price: 4500,
              stock: 12,
            ),
            sampleAddons[1],
          ],
        ),
      ],
      verify: (_) {
        verify(() => mockUpdateAddon(
              id: 1,
              name: 'Extra Shot Espresso',
              price: 4500,
              stock: 12,
            )).called(1);
        verify(() => mockGetAddons()).called(1);
      },
    );

    blocTest<AddonCubit, AddonState>(
      'deleteAddon calls delete use case, reloads addons, and emits [loading, success]',
      build: () {
        when(() => mockDeleteAddon(1)).thenAnswer((_) async {});
        when(() => mockGetAddons()).thenAnswer((_) async => [sampleAddons[1]]);
        return buildCubit();
      },
      act: (cubit) => cubit.deleteAddon(1),
      expect: () => [
        const AddonState(status: AddonStatus.loading),
        AddonState(
          status: AddonStatus.success,
          addons: [sampleAddons[1]],
        ),
      ],
      verify: (_) {
        verify(() => mockDeleteAddon(1)).called(1);
        verify(() => mockGetAddons()).called(1);
      },
    );

    blocTest<AddonCubit, AddonState>(
      'deleteAddon emits [loading, failure] when delete use case throws',
      build: () {
        when(() => mockDeleteAddon(99)).thenThrow(
          const AppDatabaseException('Add-on tidak ditemukan.'),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.deleteAddon(99),
      expect: () => [
        const AddonState(status: AddonStatus.loading),
        const AddonState(
          status: AddonStatus.failure,
          errorMessage: 'Add-on tidak ditemukan.',
        ),
      ],
    );
  });
}
