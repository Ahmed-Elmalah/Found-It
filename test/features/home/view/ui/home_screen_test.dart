import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

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
import 'package:found_it/features/home/domain/entities/home_report_item.dart';
import 'package:found_it/features/home/domain/repositories/home_repository.dart';
import 'package:found_it/features/home/domain/use_cases/get_home_feed_use_case.dart';
import 'package:found_it/features/home/view/cubit/home_cubit.dart';
import 'package:found_it/features/home/view/cubit/home_state.dart';
import 'package:found_it/features/home/view/ui/home_screen.dart';
import 'package:found_it/features/home/view/widgets/city_selection_bottom_sheet.dart';
import 'package:found_it/features/home/view/widgets/home_empty_view.dart';
import 'package:found_it/features/home/view/widgets/home_error_view.dart';
import 'package:found_it/features/home/view/widgets/home_feed_item_card.dart';
import 'package:found_it/features/home/view/widgets/home_header.dart';
import 'package:found_it/features/home/view/widgets/home_hero_banner.dart';
import 'package:found_it/features/home/view/widgets/home_shimmer_view.dart';
import 'package:found_it/features/home/view/widgets/home_success_view.dart';
import '../../../../helpers/test_app.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  bool hasActiveSession() => true;

  @override
  Stream<bool> authStateChanges() => const Stream.empty();

  @override
  Future<UserEntity?> getCurrentUser() async =>
      const UserEntity(id: 'u1', email: 'test@example.com', fullName: 'Youssef', cityId: 'c1');

  @override
  Future<void> login({required String email, required String password}) async {}

  @override
  Future<void> signUp(SignUpParams params) async {}

  @override
  Future<void> logout() async {}
}

class _FakeHomeRepository implements HomeRepository {
  List<HomeReportItem> reports = const [];
  Object? error;

  @override
  Future<List<HomeReportItem>> getHomeFeed({
    required String cityId,
    String? type = 'found',
    int limit = 20,
    int offset = 0,
  }) async {
    if (error != null) throw error!;
    return reports;
  }
}

class _FakeCityRepository implements CityRepository {
  List<CityEntity> cities = const [
    CityEntity(id: 'c1', nameEn: 'Cairo', nameAr: 'القاهرة', sortOrder: 1),
    CityEntity(id: 'c2', nameEn: 'Alexandria', nameAr: 'الإسكندرية', sortOrder: 2),
    CityEntity(id: 'c3', nameEn: 'Giza', nameAr: 'الجيزة', sortOrder: 3),
  ];
  String? selectedCityId;

  @override
  Future<List<CityEntity>> getCities() async => cities;

  @override
  Future<void> selectCity(String cityId) async {
    selectedCityId = cityId;
  }
}

void main() {
  late _FakeAuthRepository authRepo;
  late _FakeHomeRepository homeRepo;
  late _FakeCityRepository cityRepo;

  late AuthCubit authCubit;
  late HomeCubit homeCubit;

  final tReports = [
    HomeReportItem(
      id: 'rep-1',
      refCode: 'RPT-1',
      title: 'Found Airpods',
      type: 'found',
      categoryName: 'Electronics',
      categoryIcon: 'headphones',
      areaName: 'Maadi',
      cityName: 'Cairo',
      itemDate: DateTime.now().subtract(const Duration(hours: 1)),
      images: const [],
      status: 'active',
      isMine: false,
      createdAt: DateTime.now(),
    ),
  ];

  setUp(() {
    authRepo = _FakeAuthRepository();
    homeRepo = _FakeHomeRepository();
    cityRepo = _FakeCityRepository();

    authCubit = AuthCubit(
      watchAuthState: WatchAuthStateUseCase(authRepo),
      getCurrentUser: GetCurrentUserUseCase(authRepo),
      logout: LogoutUseCase(authRepo),
      hasActiveSession: HasActiveSessionUseCase(authRepo),
    );

    homeCubit = HomeCubit(
      getHomeFeedUseCase: GetHomeFeedUseCase(homeRepo),
      getCitiesUseCase: GetCitiesUseCase(cityRepo),
      selectCityUseCase: SelectCityUseCase(cityRepo),
    );
  });

  tearDown(() {
    authCubit.close();
    homeCubit.close();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    bool rtl = false,
    bool dark = false,
  }) async {
    await pumpTestApp(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<HomeCubit>.value(value: homeCubit),
        ],
        child: const HomeScreen(),
      ),
      rtl: rtl,
      dark: dark,
      padded: false,
    );
  }

  testWidgets('renders HomeScreen initial Success state with header, hero banner and feed cards',
      (tester) async {
    homeRepo.reports = tReports;
    await homeCubit.init(initialCityId: 'c1', locale: 'en');

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.byType(HomeHeader), findsOneWidget);
    expect(find.text('Cairo'), findsOneWidget);
    expect(find.byType(HomeHeroBanner), findsOneWidget);
    expect(find.byType(HomeSuccessView), findsOneWidget);
    expect(find.byType(HomeFeedItemCard), findsWidgets);
  });

  testWidgets('switches to Loading state and renders HomeShimmerView',
      (tester) async {
    homeCubit.emit(const HomeState(status: HomeStatus.loading));

    await pumpScreen(tester);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(HomeShimmerView), findsOneWidget);
  });

  testWidgets('switches to Empty state and renders HomeEmptyView with CTA',
      (tester) async {
    homeCubit.emit(const HomeState(
      status: HomeStatus.success,
      selectedCityName: 'Alexandria',
      reports: [],
    ));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.byType(HomeEmptyView), findsOneWidget);
    expect(find.text('No reports yet in Alexandria'), findsOneWidget);
    expect(find.text('Create first report'), findsOneWidget);
  });

  testWidgets('switches to Error state and renders HomeErrorView with Retry',
      (tester) async {
    homeCubit.emit(const HomeState(
      status: HomeStatus.failure,
      errorMessage: 'Unable to load reports',
    ));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.byType(HomeErrorView), findsOneWidget);
    expect(find.text('Unable to load reports'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('renders Arabic texts and RTL layout in HomeScreen',
      (tester) async {
    homeRepo.reports = tReports;
    await homeCubit.init(initialCityId: 'c1', locale: 'ar');

    await pumpScreen(tester, rtl: true);
    await tester.pumpAndSettle();

    expect(find.text('القاهرة'), findsOneWidget);
    expect(find.text('عُثر عليه'), findsWidgets);
  });

  testWidgets('renders in Dark theme without exceptions', (tester) async {
    homeRepo.reports = tReports;
    await homeCubit.init(initialCityId: 'c1', locale: 'en');

    await pumpScreen(tester, dark: true);
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('tapping city in header opens CitySelectionBottomSheet and updates city',
      (tester) async {
    homeRepo.reports = tReports;
    await homeCubit.init(initialCityId: 'c1', locale: 'en');

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    // Tap city selector in header
    await tester.tap(find.text('Cairo'));
    await tester.pumpAndSettle();

    // Verify CitySelectionBottomSheet is shown
    expect(find.byType(CitySelectionBottomSheet), findsOneWidget);
    expect(find.text('Alexandria'), findsOneWidget);

    // Tap Alexandria
    await tester.tap(find.text('Alexandria'));
    await tester.pumpAndSettle();

    // Verify bottom sheet dismissed
    expect(find.byType(CitySelectionBottomSheet), findsNothing);
  });
}
