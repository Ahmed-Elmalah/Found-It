import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  // ---------------------------------------------------------------
  // External: shared by ALL features. Registered once, here only.
  //   Data sources get them with sl(), e.g.
  //   ..registerLazySingleton<CityLocalDataSource>(
  //       () => CityLocalDataSourceImpl(sl<SharedPreferences>()))
  // Supabase.initialize() must run before this (see main.dart).
  // ---------------------------------------------------------------
  final prefs = await SharedPreferences.getInstance();

  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerSingleton<SupabaseClient>(Supabase.instance.client);
}