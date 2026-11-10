import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/core/database/app_database.dart';
import 'package:vonte_pos/core/di/injection.dart';
import 'package:vonte_pos/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:vonte_pos/features/auth/domain/repositories/auth_repository.dart';
import 'package:vonte_pos/features/auth/domain/usecases/get_current_session.dart';
import 'package:vonte_pos/features/auth/domain/usecases/login_user.dart';
import 'package:vonte_pos/features/auth/domain/usecases/logout.dart';
import 'package:vonte_pos/features/auth/domain/usecases/register_user.dart';
import 'package:vonte_pos/features/auth/presentation/cubit/auth_cubit.dart';

void main() {
  tearDown(() async {
    await getIt.reset();
  });

  group('Injection', () {
    test('registers AppDatabase and Auth dependencies in GetIt', () async {
      await initDependencies();

      expect(getIt.isRegistered<AppDatabase>(), isTrue);
      final db1 = getIt<AppDatabase>();
      final db2 = getIt<AppDatabase>();
      expect(identical(db1, db2), isTrue);

      expect(getIt.isRegistered<AuthLocalDataSource>(), isTrue);
      expect(getIt.isRegistered<AuthRepository>(), isTrue);
      expect(getIt.isRegistered<RegisterUser>(), isTrue);
      expect(getIt.isRegistered<LoginUser>(), isTrue);
      expect(getIt.isRegistered<Logout>(), isTrue);
      expect(getIt.isRegistered<GetCurrentSession>(), isTrue);
      expect(getIt.isRegistered<AuthCubit>(), isTrue);
    });

    test('allows injecting custom AppDatabase instance', () async {
      final customDb = AppDatabase.inMemory();
      await initDependencies(appDatabase: customDb);

      expect(getIt<AppDatabase>(), same(customDb));
    });
  });
}

