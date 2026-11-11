import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/features/auth/data/auth_data_source.dart';
import 'package:found_it/features/auth/data/auth_repository_impl.dart';
import 'package:found_it/features/auth/domain/auth_repository.dart';
import 'package:found_it/features/auth/domain/has_active_session_use_case.dart';
import 'package:found_it/features/onboarding/data/onboarding_local_data_source.dart';
import 'package:found_it/features/onboarding/data/onboarding_repository_impl.dart';
import 'package:found_it/features/onboarding/domain/complete_onboarding_use_case.dart';
import 'package:found_it/features/onboarding/domain/is_first_launch_use_case.dart';
import 'package:found_it/features/onboarding/domain/onboarding_repository.dart';
import 'package:found_it/features/onboarding/view/cubit/onboarding_cubit.dart';
import 'package:found_it/features/onboarding/view/cubit/splash_cubit.dart';
import 'package:found_it/features/reports/data/reports_remote_data_source.dart';
import 'package:found_it/features/reports/data/reports_repository_impl.dart';
import 'package:found_it/features/reports/data/services/photo_picker_service.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';
import 'package:found_it/features/reports/domain/use_cases/create_report_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_categories_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_city_areas_use_case.dart';
import 'package:found_it/features/reports/view/cubit/create_report_cubit.dart';

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

  _registerAuth();
  _registerOnboarding();
  _registerReports();
}

// ---------------------------------------------------------------------
// Reports
// ---------------------------------------------------------------------
void _registerReports() {
  sl
    ..registerLazySingleton<PhotoPickerService>(
      () => PhotoPickerServiceImpl(),
    )
    ..registerLazySingleton<ReportsRemoteDataSource>(
      () => ReportsRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<ReportsRepository>(
      () => ReportsRepositoryImpl(
        remoteDataSource: sl(),
        prefs: sl(),
        supabase: sl(),
      ),
    )
    ..registerLazySingleton(() => GetCategoriesUseCase(sl()))
    ..registerLazySingleton(() => GetCityAreasUseCase(sl()))
    ..registerLazySingleton(() => CreateReportUseCase(sl()))
    ..registerFactory(
      () => CreateReportCubit(
        getCategories: sl(),
        getCityAreas: sl(),
        createReport: sl(),
        photoPicker: sl(),
        repository: sl(),
      ),
    );
}

// ---------------------------------------------------------------------
// Auth (Ahmed) — only the session check for now, login/sign up in stage 8
// ---------------------------------------------------------------------
void _registerAuth() {
  sl
    ..registerLazySingleton<AuthDataSource>(() => AuthDataSourceImpl(sl()))
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()))
    ..registerLazySingleton(() => HasActiveSessionUseCase(sl()));
}

// ---------------------------------------------------------------------
// Onboarding + Splash (Ahmed)
// ---------------------------------------------------------------------
void _registerOnboarding() {
  sl
    ..registerLazySingleton<OnboardingLocalDataSource>(
      () => OnboardingLocalDataSourceImpl(sl()),
    )
    ..registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => IsFirstLaunchUseCase(sl()))
    ..registerLazySingleton(() => CompleteOnboardingUseCase(sl()))
    ..registerFactory(() => SplashCubit(sl(), sl()))
    ..registerFactory(() => OnboardingCubit(sl()));
}
