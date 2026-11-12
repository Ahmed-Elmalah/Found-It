import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/core/widgets/app_button.dart';
import 'package:found_it/core/widgets/error_banner.dart';
import 'package:found_it/features/auth/domain/auth_repository.dart';
import 'package:found_it/features/auth/domain/get_current_user_use_case.dart';
import 'package:found_it/features/auth/domain/has_active_session_use_case.dart';
import 'package:found_it/features/auth/domain/logout_use_case.dart';
import 'package:found_it/features/auth/domain/sign_up_params.dart';
import 'package:found_it/features/auth/domain/user_entity.dart';
import 'package:found_it/features/auth/domain/watch_auth_state_use_case.dart';
import 'package:found_it/features/auth/view/cubit/auth_cubit.dart';
import 'package:found_it/features/city/domain/city_entity.dart';
import 'package:found_it/features/city/domain/city_repository.dart';
import 'package:found_it/features/city/domain/get_cities_use_case.dart';
import 'package:found_it/features/city/domain/select_city_use_case.dart';
import 'package:found_it/features/city/view/cubit/city_cubit.dart';
import 'package:found_it/features/city/view/ui/choose_city_screen.dart';

import '../../../../helpers/test_app.dart';

class _FakeCityRepository implements CityRepository {
  List<CityEntity> cities = const [
    CityEntity(id: 'c1', nameEn: 'Cairo', nameAr: 'القاهرة', sortOrder: 1),
    CityEntity(id: 'c2', nameEn: 'Alexandria', nameAr: 'الإسكندرية', sortOrder: 2),
  ];
  String? selectedCityId;

  @override
  Future<List<CityEntity>> getCities() async => cities;

  @override
  Future<void> selectCity(String cityId) async {
    selectedCityId = cityId;
  }
}

class _FakeAuthRepository implements AuthRepository {
  @override
  bool hasActiveSession() => true;

  @override
  Stream<bool> authStateChanges() => const Stream.empty();

  @override
  Future<UserEntity?> getCurrentUser() async =>
      const UserEntity(id: 'u1', email: 'test@example.com', fullName: 'Youssef');

  @override
  Future<void> login({required String email, required String password}) async {}

  @override
  Future<void> signUp(SignUpParams params) async {}

  @override
  Future<void> logout() async {}
}

void main() {
  late _FakeCityRepository cityRepo;
  late _FakeAuthRepository authRepo;
  late CityCubit cityCubit;
  late AuthCubit authCubit;

  setUp(() {
    cityRepo = _FakeCityRepository();
    authRepo = _FakeAuthRepository();

    cityCubit = CityCubit(
      getCitiesUseCase: GetCitiesUseCase(cityRepo),
      selectCityUseCase: SelectCityUseCase(cityRepo),
    );

    authCubit = AuthCubit(
      watchAuthState: WatchAuthStateUseCase(authRepo),
      getCurrentUser: GetCurrentUserUseCase(authRepo),
      logout: LogoutUseCase(authRepo),
      hasActiveSession: HasActiveSessionUseCase(authRepo),
    );
  });

  tearDown(() {
    cityCubit.close();
    authCubit.close();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    bool dark = false,
    bool rtl = false,
  }) async {
    final router = GoRouter(
      initialLocation: AppRoutes.city,
      routes: [
        GoRoute(
          path: AppRoutes.city,
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<CityCubit>.value(value: cityCubit),
              BlocProvider<AuthCubit>.value(value: authCubit),
            ],
            child: const ChooseCityScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const Text('HOME SCREEN'),
        ),
      ],
    );

    await pumpTestRouterApp(tester, router, dark: dark, rtl: rtl);
  }

  testWidgets('renders title, subtitle, cities, and continue button', (tester) async {
    await cityCubit.loadCities();
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Choose your city'), findsOneWidget);
    expect(find.text('Cairo'), findsOneWidget);
    expect(find.text('Alexandria'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('renders Arabic texts and RTL layout', (tester) async {
    await cityCubit.loadCities();
    await pumpScreen(tester, rtl: true);
    await tester.pumpAndSettle();

    expect(find.text('اختر مدينتك'), findsOneWidget);
    expect(find.text('القاهرة'), findsOneWidget);
    expect(find.text('الإسكندرية'), findsOneWidget);
    expect(find.text('متابعة'), findsOneWidget);
  });

  testWidgets('shows ErrorBanner when tapping Continue without selecting a city', (tester) async {
    await cityCubit.loadCities();
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.byType(ErrorBanner), findsNothing);

    // Tap continue without selecting
    await tester.tap(find.widgetWithText(AppButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorBanner), findsOneWidget);
    expect(find.textContaining('Location Required:'), findsOneWidget);
    expect(find.textContaining('Please select a city to continue.'), findsOneWidget);
  });

  testWidgets('selecting a city and tapping Continue proceeds to home', (tester) async {
    await cityCubit.loadCities();
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    // Select Cairo
    await tester.tap(find.text('Cairo'));
    await tester.pumpAndSettle();

    // Now tap Continue
    await tester.tap(find.widgetWithText(AppButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(cityRepo.selectedCityId, 'c1');
    expect(find.text('HOME SCREEN'), findsOneWidget);
  });
}
