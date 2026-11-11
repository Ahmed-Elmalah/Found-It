import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  // ---------------------------------------------------------------
  // Rules (follow them in every feature):
  //   registerLazySingleton -> data sources, repositories, use cases
  //   registerFactory       -> Cubits (a fresh one per screen)
  //   registerSingleton     -> things created at startup (e.g. SharedPreferences)
  //
  // Registration order inside a feature:
  //   data source -> repository -> use cases -> cubit
  //
  // Example for a feature:
  //   sl
  //     ..registerLazySingleton<AuthDataSource>(() => AuthDataSourceImpl())
  //     ..registerLazySingleton<AuthRepository>(
  //         () => AuthRepositoryImpl(sl()))
  //     ..registerLazySingleton(() => LoginUseCase(sl()))
  //     ..registerFactory(() => LoginCubit(sl()));
  // ---------------------------------------------------------------
}