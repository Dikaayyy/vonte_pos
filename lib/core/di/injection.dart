import 'package:get_it/get_it.dart';

import '../database/app_database.dart';

final getIt = GetIt.instance;
final sl = getIt;

Future<void> initDependencies({AppDatabase? appDatabase}) async {
  final database = appDatabase ?? AppDatabase();
  getIt.registerLazySingleton<AppDatabase>(() => database);
}

