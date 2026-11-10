import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_session.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/category/data/datasources/category_local_data_source.dart';
import '../../features/category/data/repositories/category_repository_impl.dart';
import '../../features/category/domain/repositories/category_repository.dart';
import '../../features/category/domain/usecases/create_category.dart';
import '../../features/category/domain/usecases/delete_category.dart';
import '../../features/category/domain/usecases/get_categories.dart';
import '../../features/category/domain/usecases/update_category.dart';
import '../../features/category/presentation/cubit/category_cubit.dart';
import '../../features/addon/data/datasources/addon_local_data_source.dart';
import '../../features/addon/data/repositories/addon_repository_impl.dart';
import '../../features/addon/domain/repositories/addon_repository.dart';
import '../../features/addon/domain/usecases/create_addon.dart';
import '../../features/addon/domain/usecases/delete_addon.dart';
import '../../features/addon/domain/usecases/get_addon_by_id.dart';
import '../../features/addon/domain/usecases/get_addons.dart';
import '../../features/addon/domain/usecases/update_addon.dart';
import '../../features/addon/presentation/cubit/addon_cubit.dart';
import '../../features/cashier/presentation/cubit/cart_cubit.dart';
import '../../features/cashier/presentation/cubit/checkout_cubit.dart';
import '../../features/product/data/datasources/product_local_data_source.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/data/services/image_picker_service.dart';
import '../../features/product/data/services/photo_storage.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/domain/usecases/create_product.dart';
import '../../features/product/domain/usecases/delete_product.dart';
import '../../features/product/domain/usecases/get_product_by_id.dart';
import '../../features/product/domain/usecases/get_products.dart';
import '../../features/product/domain/usecases/update_product.dart';
import '../../features/product/presentation/cubit/product_cubit.dart';
import '../../features/store_profile/data/datasources/store_profile_local_data_source.dart';
import '../../features/store_profile/data/repositories/store_profile_repository_impl.dart';
import '../../features/store_profile/domain/repositories/store_profile_repository.dart';
import '../../features/store_profile/domain/usecases/get_store_profile.dart';
import '../../features/store_profile/domain/usecases/seed_sample_data.dart';
import '../../features/store_profile/domain/usecases/update_store_profile.dart';
import '../../features/store_profile/presentation/cubit/store_profile_cubit.dart';
import '../../features/transaction/data/datasources/transaction_local_data_source.dart';
import '../../features/transaction/data/repositories/transaction_repository_impl.dart';
import '../../features/transaction/domain/repositories/transaction_repository.dart';
import '../../features/transaction/domain/services/invoice_number_generator.dart';
import '../../features/transaction/domain/usecases/checkout_use_case.dart';
import '../database/app_database.dart';
import '../storage/app_directory_provider.dart';

final getIt = GetIt.instance;
final sl = getIt;

Future<void> initDependencies({AppDatabase? appDatabase}) async {
  // 1. Core & Database & Storage
  final database = appDatabase ?? AppDatabase();
  if (!getIt.isRegistered<AppDatabase>()) {
    getIt.registerLazySingleton<AppDatabase>(() => database);
  }
  if (!getIt.isRegistered<AppDirectoryProvider>()) {
    getIt.registerLazySingleton<AppDirectoryProvider>(
      () => const AppDirectoryProviderImpl(),
    );
  }
  if (!getIt.isRegistered<PhotoStorage>()) {
    getIt.registerLazySingleton<PhotoStorage>(
      () => PhotoStorageImpl(getIt<AppDirectoryProvider>()),
    );
  }
  if (!getIt.isRegistered<AppImagePickerService>()) {
    getIt.registerLazySingleton<AppImagePickerService>(
      () => AppImagePickerServiceImpl(),
    );
  }
  if (!getIt.isRegistered<InvoiceNumberGenerator>()) {
    getIt.registerLazySingleton<InvoiceNumberGenerator>(
      () => const InvoiceNumberGenerator(),
    );
  }

  // 2. Data Sources
  if (!getIt.isRegistered<AuthLocalDataSource>()) {
    getIt.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(getIt<AppDatabase>()),
    );
  }
  if (!getIt.isRegistered<CategoryLocalDataSource>()) {
    getIt.registerLazySingleton<CategoryLocalDataSource>(
      () => CategoryLocalDataSourceImpl(getIt<AppDatabase>()),
    );
  }
  if (!getIt.isRegistered<AddonLocalDataSource>()) {
    getIt.registerLazySingleton<AddonLocalDataSource>(
      () => AddonLocalDataSourceImpl(getIt<AppDatabase>()),
    );
  }
  if (!getIt.isRegistered<ProductLocalDataSource>()) {
    getIt.registerLazySingleton<ProductLocalDataSource>(
      () => ProductLocalDataSourceImpl(getIt<AppDatabase>()),
    );
  }
  if (!getIt.isRegistered<StoreProfileLocalDataSource>()) {
    getIt.registerLazySingleton<StoreProfileLocalDataSource>(
      () => StoreProfileLocalDataSourceImpl(getIt<AppDatabase>()),
    );
  }
  if (!getIt.isRegistered<TransactionLocalDataSource>()) {
    getIt.registerLazySingleton<TransactionLocalDataSource>(
      () => TransactionLocalDataSourceImpl(getIt<AppDatabase>()),
    );
  }

  // 3. Repositories
  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt<AuthLocalDataSource>()),
    );
  }
  if (!getIt.isRegistered<CategoryRepository>()) {
    getIt.registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(getIt<CategoryLocalDataSource>()),
    );
  }
  if (!getIt.isRegistered<AddonRepository>()) {
    getIt.registerLazySingleton<AddonRepository>(
      () => AddonRepositoryImpl(getIt<AddonLocalDataSource>()),
    );
  }
  if (!getIt.isRegistered<ProductRepository>()) {
    getIt.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(
        getIt<ProductLocalDataSource>(),
        getIt<PhotoStorage>(),
      ),
    );
  }
  if (!getIt.isRegistered<StoreProfileRepository>()) {
    getIt.registerLazySingleton<StoreProfileRepository>(
      () => StoreProfileRepositoryImpl(getIt<StoreProfileLocalDataSource>()),
    );
  }
  if (!getIt.isRegistered<TransactionRepository>()) {
    getIt.registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImpl(
        getIt<TransactionLocalDataSource>(),
        getIt<InvoiceNumberGenerator>(),
      ),
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
  if (!getIt.isRegistered<GetCategories>()) {
    getIt.registerLazySingleton<GetCategories>(
      () => GetCategories(getIt<CategoryRepository>()),
    );
  }
  if (!getIt.isRegistered<CreateCategory>()) {
    getIt.registerLazySingleton<CreateCategory>(
      () => CreateCategory(getIt<CategoryRepository>()),
    );
  }
  if (!getIt.isRegistered<UpdateCategory>()) {
    getIt.registerLazySingleton<UpdateCategory>(
      () => UpdateCategory(getIt<CategoryRepository>()),
    );
  }
  if (!getIt.isRegistered<DeleteCategory>()) {
    getIt.registerLazySingleton<DeleteCategory>(
      () => DeleteCategory(getIt<CategoryRepository>()),
    );
  }
  if (!getIt.isRegistered<GetAddons>()) {
    getIt.registerLazySingleton<GetAddons>(
      () => GetAddons(getIt<AddonRepository>()),
    );
  }
  if (!getIt.isRegistered<GetAddonById>()) {
    getIt.registerLazySingleton<GetAddonById>(
      () => GetAddonById(getIt<AddonRepository>()),
    );
  }
  if (!getIt.isRegistered<CreateAddon>()) {
    getIt.registerLazySingleton<CreateAddon>(
      () => CreateAddon(getIt<AddonRepository>()),
    );
  }
  if (!getIt.isRegistered<UpdateAddon>()) {
    getIt.registerLazySingleton<UpdateAddon>(
      () => UpdateAddon(getIt<AddonRepository>()),
    );
  }
  if (!getIt.isRegistered<DeleteAddon>()) {
    getIt.registerLazySingleton<DeleteAddon>(
      () => DeleteAddon(getIt<AddonRepository>()),
    );
  }
  if (!getIt.isRegistered<GetProducts>()) {
    getIt.registerLazySingleton<GetProducts>(
      () => GetProducts(getIt<ProductRepository>()),
    );
  }
  if (!getIt.isRegistered<GetProductById>()) {
    getIt.registerLazySingleton<GetProductById>(
      () => GetProductById(getIt<ProductRepository>()),
    );
  }
  if (!getIt.isRegistered<CreateProduct>()) {
    getIt.registerLazySingleton<CreateProduct>(
      () => CreateProduct(getIt<ProductRepository>()),
    );
  }
  if (!getIt.isRegistered<UpdateProduct>()) {
    getIt.registerLazySingleton<UpdateProduct>(
      () => UpdateProduct(getIt<ProductRepository>()),
    );
  }
  if (!getIt.isRegistered<DeleteProduct>()) {
    getIt.registerLazySingleton<DeleteProduct>(
      () => DeleteProduct(getIt<ProductRepository>()),
    );
  }
  if (!getIt.isRegistered<GetStoreProfile>()) {
    getIt.registerLazySingleton<GetStoreProfile>(
      () => GetStoreProfile(getIt<StoreProfileRepository>()),
    );
  }
  if (!getIt.isRegistered<UpdateStoreProfile>()) {
    getIt.registerLazySingleton<UpdateStoreProfile>(
      () => UpdateStoreProfile(getIt<StoreProfileRepository>()),
    );
  }
  if (!getIt.isRegistered<SeedSampleData>()) {
    getIt.registerLazySingleton<SeedSampleData>(
      () => SeedSampleData(getIt<StoreProfileRepository>()),
    );
  }
  if (!getIt.isRegistered<CheckoutUseCase>()) {
    getIt.registerLazySingleton<CheckoutUseCase>(
      () => CheckoutUseCase(getIt<TransactionRepository>()),
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
  if (!getIt.isRegistered<CategoryCubit>()) {
    getIt.registerFactory<CategoryCubit>(
      () => CategoryCubit(
        getCategoriesUseCase: getIt<GetCategories>(),
        createCategoryUseCase: getIt<CreateCategory>(),
        updateCategoryUseCase: getIt<UpdateCategory>(),
        deleteCategoryUseCase: getIt<DeleteCategory>(),
      ),
    );
  }
  if (!getIt.isRegistered<AddonCubit>()) {
    getIt.registerFactory<AddonCubit>(
      () => AddonCubit(
        getAddonsUseCase: getIt<GetAddons>(),
        createAddonUseCase: getIt<CreateAddon>(),
        updateAddonUseCase: getIt<UpdateAddon>(),
        deleteAddonUseCase: getIt<DeleteAddon>(),
      ),
    );
  }
  if (!getIt.isRegistered<ProductCubit>()) {
    getIt.registerFactory<ProductCubit>(
      () => ProductCubit(
        getProductsUseCase: getIt<GetProducts>(),
        createProductUseCase: getIt<CreateProduct>(),
        updateProductUseCase: getIt<UpdateProduct>(),
        deleteProductUseCase: getIt<DeleteProduct>(),
      ),
    );
  }
  if (!getIt.isRegistered<StoreProfileCubit>()) {
    getIt.registerFactory<StoreProfileCubit>(
      () => StoreProfileCubit(
        getStoreProfileUseCase: getIt<GetStoreProfile>(),
        updateStoreProfileUseCase: getIt<UpdateStoreProfile>(),
        seedSampleDataUseCase: getIt<SeedSampleData>(),
      ),
    );
  }
  if (!getIt.isRegistered<CartCubit>()) {
    getIt.registerFactory<CartCubit>(
      () => CartCubit(
        getProductById: getIt<GetProductById>(),
        getAddonById: getIt<GetAddonById>(),
      ),
    );
  }
  if (!getIt.isRegistered<CheckoutCubit>()) {
    getIt.registerFactory<CheckoutCubit>(
      () => CheckoutCubit(
        checkoutUseCase: getIt<CheckoutUseCase>(),
      ),
    );
  }
}
