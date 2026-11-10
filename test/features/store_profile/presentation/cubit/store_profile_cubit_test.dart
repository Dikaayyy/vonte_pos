import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vonte_pos/core/constants/app_strings.dart';
import 'package:vonte_pos/core/error/exceptions.dart';
import 'package:vonte_pos/features/store_profile/domain/entities/store_profile.dart';
import 'package:vonte_pos/features/store_profile/domain/usecases/get_store_profile.dart';
import 'package:vonte_pos/features/store_profile/domain/usecases/seed_sample_data.dart';
import 'package:vonte_pos/features/store_profile/domain/usecases/update_store_profile.dart';
import 'package:vonte_pos/features/store_profile/presentation/cubit/store_profile_cubit.dart';
import 'package:vonte_pos/features/store_profile/presentation/cubit/store_profile_state.dart';

class MockGetStoreProfile extends Mock implements GetStoreProfile {}

class MockUpdateStoreProfile extends Mock implements UpdateStoreProfile {}

class MockSeedSampleData extends Mock implements SeedSampleData {}

void main() {
  late MockGetStoreProfile mockGetStoreProfile;
  late MockUpdateStoreProfile mockUpdateStoreProfile;
  late MockSeedSampleData mockSeedSampleData;

  const testProfile = StoreProfile(
    id: 1,
    name: 'Vonte Coffee',
    address: 'Jl. Merdeka No. 1',
    phone: '081234567890',
    receiptFooter: 'Terima kasih atas kunjungan Anda',
  );

  setUpAll(() {
    registerFallbackValue(testProfile);
  });

  setUp(() {
    mockGetStoreProfile = MockGetStoreProfile();
    mockUpdateStoreProfile = MockUpdateStoreProfile();
    mockSeedSampleData = MockSeedSampleData();
  });

  StoreProfileCubit buildCubit() {
    return StoreProfileCubit(
      getStoreProfileUseCase: mockGetStoreProfile,
      updateStoreProfileUseCase: mockUpdateStoreProfile,
      seedSampleDataUseCase: mockSeedSampleData,
    );
  }

  group('StoreProfileCubit', () {
    test('initial state is correct', () {
      final cubit = buildCubit();
      expect(cubit.state, const StoreProfileState());
      expect(cubit.state.status, equals(StoreProfileStatus.initial));
      expect(cubit.state.profile, isNull);
    });

    blocTest<StoreProfileCubit, StoreProfileState>(
      'loadProfile emits [loading, success] on success',
      build: () {
        when(() => mockGetStoreProfile()).thenAnswer((_) async => testProfile);
        return buildCubit();
      },
      act: (cubit) => cubit.loadProfile(),
      expect: () => [
        const StoreProfileState(status: StoreProfileStatus.loading),
        const StoreProfileState(
          status: StoreProfileStatus.success,
          profile: testProfile,
        ),
      ],
      verify: (_) {
        verify(() => mockGetStoreProfile()).called(1);
      },
    );

    blocTest<StoreProfileCubit, StoreProfileState>(
      'loadProfile emits [loading, failure] on error',
      build: () {
        when(() => mockGetStoreProfile())
            .thenThrow(const AppDatabaseException('Database error'));
        return buildCubit();
      },
      act: (cubit) => cubit.loadProfile(),
      expect: () => [
        const StoreProfileState(status: StoreProfileStatus.loading),
        const StoreProfileState(
          status: StoreProfileStatus.failure,
          errorMessage: 'Database error',
        ),
      ],
    );

    blocTest<StoreProfileCubit, StoreProfileState>(
      'updateProfile emits [loading, success] with userMessage',
      build: () {
        when(() => mockUpdateStoreProfile(any())).thenAnswer(
          (_) async => const StoreProfile(
            id: 1,
            name: 'Vonte Coffee Baru',
            address: 'Jl. Merdeka No. 2',
            phone: '081299999999',
            receiptFooter: 'Sampai jumpa!',
          ),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.updateProfile(
        name: 'Vonte Coffee Baru',
        address: 'Jl. Merdeka No. 2',
        phone: '081299999999',
        receiptFooter: 'Sampai jumpa!',
      ),
      expect: () => [
        const StoreProfileState(status: StoreProfileStatus.loading),
        const StoreProfileState(
          status: StoreProfileStatus.success,
          profile: StoreProfile(
            id: 1,
            name: 'Vonte Coffee Baru',
            address: 'Jl. Merdeka No. 2',
            phone: '081299999999',
            receiptFooter: 'Sampai jumpa!',
          ),
          userMessage: AppStrings.storeProfileSaved,
        ),
      ],
    );

    blocTest<StoreProfileCubit, StoreProfileState>(
      'seedData emits [loading, success] with userMessage when seeding succeeds',
      build: () {
        when(() => mockSeedSampleData()).thenAnswer((_) async => true);
        return buildCubit();
      },
      act: (cubit) => cubit.seedData(),
      expect: () => [
        const StoreProfileState(status: StoreProfileStatus.loading),
        const StoreProfileState(
          status: StoreProfileStatus.success,
          userMessage: AppStrings.seedSampleDataSuccess,
        ),
      ],
    );

    blocTest<StoreProfileCubit, StoreProfileState>(
      'seedData emits [loading, failure] when table is not empty',
      build: () {
        when(() => mockSeedSampleData()).thenAnswer((_) async => false);
        return buildCubit();
      },
      act: (cubit) => cubit.seedData(),
      expect: () => [
        const StoreProfileState(status: StoreProfileStatus.loading),
        const StoreProfileState(
          status: StoreProfileStatus.failure,
          errorMessage: AppStrings.seedSampleDataAlreadyPopulated,
        ),
      ],
    );
  });
}

