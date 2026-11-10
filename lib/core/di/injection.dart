import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_session.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../database/app_database.dart';

final getIt = GetIt.instance;
final sl = getIt;

Future<void> initDependencies({AppDatabase? appDatabase}) async {
  // 1. Core & Database
  final database = appDatabase ?? AppDatabase();
  if (!getIt.isRegistered<AppDatabase>()) {
    getIt.registerLazySingleton<AppDatabase>(() => database);
  }

  // 2. Data Sources
  if (!getIt.isRegistered<AuthLocalDataSource>()) {
    getIt.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(getIt<AppDatabase>()),
    );
  }

  // 3. Repositories
  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt<AuthLocalDataSource>()),
    );
  }

  // 4. Use Cases
  if (!getIt.isRegistered<RegisterUser>()) {
    getIt.registerLazySingleton<RegisterUser>(
      () => RegisterUser(getIt<AuthRepository>()),
    );
  }
  if (!getIt.isRegistered<LoginUser>()) {
    getIt.registerLazySingleton<LoginUser>(
      () => LoginUser(getIt<AuthRepository>()),
    );
  }
  if (!getIt.isRegistered<Logout>()) {
    getIt.registerLazySingleton<Logout>(
      () => Logout(getIt<AuthRepository>()),
    );
  }
  if (!getIt.isRegistered<GetCurrentSession>()) {
    getIt.registerLazySingleton<GetCurrentSession>(
      () => GetCurrentSession(getIt<AuthRepository>()),
    );
  }

  // 5. Cubits (Factory)
  if (!getIt.isRegistered<AuthCubit>()) {
    getIt.registerFactory<AuthCubit>(
      () => AuthCubit(
        getCurrentSessionUseCase: getIt<GetCurrentSession>(),
        loginUserUseCase: getIt<LoginUser>(),
        registerUserUseCase: getIt<RegisterUser>(),
        logoutUseCase: getIt<Logout>(),
      ),
    );
  }
}
