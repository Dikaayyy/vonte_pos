import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vonte_pos/features/addon/domain/entities/addon.dart';
import 'package:vonte_pos/features/addon/domain/repositories/addon_repository.dart';
import 'package:vonte_pos/features/addon/domain/usecases/get_addon_by_id.dart';

class MockAddonRepository extends Mock implements AddonRepository {}

void main() {
  late MockAddonRepository mockRepository;
  late GetAddonById useCase;

  setUp(() {
    mockRepository = MockAddonRepository();
    useCase = GetAddonById(mockRepository);
  });

  const testAddon = Addon(
    id: 1,
    name: 'Extra Shot',
    price: 3000,
    stock: 15,
  );

  test('calls repository.getAddonById and returns addon when found', () async {
    when(() => mockRepository.getAddonById(1))
        .thenAnswer((_) async => testAddon);

    final result = await useCase(1);

    expect(result, testAddon);
    verify(() => mockRepository.getAddonById(1)).called(1);
  });

  test('calls repository.getAddonById and returns null when not found', () async {
    when(() => mockRepository.getAddonById(99))
        .thenAnswer((_) async => null);

    final result = await useCase(99);

    expect(result, isNull);
    verify(() => mockRepository.getAddonById(99)).called(1);
  });
}

