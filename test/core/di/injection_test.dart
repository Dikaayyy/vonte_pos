import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/core/database/app_database.dart';
import 'package:vonte_pos/core/di/injection.dart';

void main() {
  tearDown(() async {
    await getIt.reset();
  });

  group('Injection', () {
    test('registers AppDatabase as lazy singleton in GetIt', () async {
      await initDependencies();

      expect(getIt.isRegistered<AppDatabase>(), isTrue);
      final db1 = getIt<AppDatabase>();
      final db2 = getIt<AppDatabase>();
      expect(identical(db1, db2), isTrue);
    });

    test('allows injecting custom AppDatabase instance', () async {
      final customDb = AppDatabase.inMemory();
      await initDependencies(appDatabase: customDb);

      expect(getIt<AppDatabase>(), same(customDb));
    });
  });
}

