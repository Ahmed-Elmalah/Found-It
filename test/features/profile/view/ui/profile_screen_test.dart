import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:found_it/core/preferences/app_preferences_cubit.dart';
import 'package:found_it/features/auth/domain/auth_repository.dart';
import 'package:found_it/features/auth/domain/get_current_user_use_case.dart';
import 'package:found_it/features/auth/domain/has_active_session_use_case.dart';
import 'package:found_it/features/auth/domain/logout_use_case.dart';
import 'package:found_it/features/auth/domain/sign_up_params.dart';
import 'package:found_it/features/auth/domain/user_entity.dart';
import 'package:found_it/features/auth/domain/watch_auth_state_use_case.dart';
import 'package:found_it/features/auth/view/cubit/auth_cubit.dart';
import 'package:found_it/features/profile/domain/entities/city_entity.dart';
import 'package:found_it/features/profile/domain/entities/user_profile_entity.dart';
import 'package:found_it/features/profile/domain/repositories/profile_repository.dart';
import 'package:found_it/features/profile/domain/use_cases/get_active_cities_use_case.dart';
import 'package:found_it/features/profile/domain/use_cases/get_profile_use_case.dart';
import 'package:found_it/features/profile/domain/use_cases/set_my_city_use_case.dart';
import 'package:found_it/features/profile/domain/use_cases/update_profile_use_case.dart';
import 'package:found_it/features/profile/view/cubit/profile_cubit.dart';
import 'package:found_it/features/profile/view/ui/profile_screen.dart';
import 'package:found_it/features/profile/view/widgets/profile_header.dart';
import 'package:found_it/features/reports/domain/entities/area_entity.dart';
import 'package:found_it/features/reports/domain/entities/category_entity.dart';
import 'package:found_it/features/reports/domain/entities/create_report_params.dart';
import 'package:found_it/features/reports/domain/entities/report_counts_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_entity.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';
import 'package:found_it/features/reports/domain/use_cases/get_my_reports_counts_use_case.dart';

import '../../../../helpers/test_app.dart';

class _FakeProfileRepo implements ProfileRepository {
  final profile = UserProfileEntity(
    id: 'user_1',
    email: 'adham@example.com',
    fullName: 'Adham Alrefaay',
    phone: '01012345678',
    role: 'user',
    cityId: 'city_cairo',
    cityNameEn: 'Cairo',
    cityNameAr: 'القاهرة',
    createdAt: DateTime(2026, 11, 1),
  );

  final cities = const [
    CityEntity(id: 'city_cairo', nameEn: 'Cairo', nameAr: 'القاهرة', sortOrder: 1),
  ];

  @override
  Future<UserProfileEntity> getMyProfile() async => profile;

  @override
  Future<List<CityEntity>> getActiveCities() async => cities;

  @override
  Future<void> updateProfile({
    required String fullName,
    String? phone,
    String? address,
  }) async {}

  @override
  Future<void> setMyCity(String cityId) async {}
}

class _FakeReportsRepoForProfileScreen implements ReportsRepository {
  @override
  Future<ReportCountsEntity> getMyReportsCounts() async => const ReportCountsEntity(
        total: 3,
        active: 2,
        matching: 1,
        recovered: 0,
      );

  @override
  Future<String> createReport(CreateReportParams params) => throw UnimplementedError();
  @override
  Future<List<CategoryEntity>> getCategories() => throw UnimplementedError();
  @override
  Future<List<AreaEntity>> getCityAreas({required String cityId, required String lang}) =>
      throw UnimplementedError();
  @override
  Future<List<ReportEntity>> getMyReports({String? status}) => throw UnimplementedError();
  @override
  Future<String> getSelectedCityId() => throw UnimplementedError();
  @override
  Future<void> softDeleteReport(String reportId) => throw UnimplementedError();
  @override
  Future<ReportEntity> updateReport({
    required String reportId,
    String? title,
    String? description,
    String? type,
    String? categoryId,
    String? areaId,
    DateTime? itemDate,
  }) =>
      throw UnimplementedError();
}

class _FakeAuthRepo implements AuthRepository {
  @override
  Future<void> login({required String email, required String password}) async {}

  @override
  Future<void> signUp(SignUpParams params) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<UserEntity?> getCurrentUser() async => null;

  @override
  bool hasActiveSession() => true;

  @override
  Stream<bool> authStateChanges() => Stream.value(true);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfileScreen Widget Test', () {
    late _FakeProfileRepo profileRepo;
    late _FakeReportsRepoForProfileScreen reportsRepo;
    late ProfileCubit profileCubit;
    late AuthCubit authCubit;
    late AppPreferencesCubit prefsCubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      prefsCubit = AppPreferencesCubit(prefs);

      final authRepo = _FakeAuthRepo();
      authCubit = AuthCubit(
        watchAuthState: WatchAuthStateUseCase(authRepo),
        getCurrentUser: GetCurrentUserUseCase(authRepo),
        logout: LogoutUseCase(authRepo),
        hasActiveSession: HasActiveSessionUseCase(authRepo),
      );

      profileRepo = _FakeProfileRepo();
      reportsRepo = _FakeReportsRepoForProfileScreen();
      profileCubit = ProfileCubit(
        GetProfileUseCase(profileRepo),
        UpdateProfileUseCase(profileRepo),
        SetMyCityUseCase(profileRepo),
        GetActiveCitiesUseCase(profileRepo),
        GetMyReportsCountsUseCase(reportsRepo),
      );
    });

    tearDown(() async {
      await profileCubit.close();
      await authCubit.close();
      await prefsCubit.close();
    });

    testWidgets('renders profile header, settings tiles, and logout button', (tester) async {
      await pumpTestApp(
        tester,
        MultiBlocProvider(
          providers: [
            BlocProvider<ProfileCubit>.value(value: profileCubit),
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<AppPreferencesCubit>.value(value: prefsCubit),
          ],
          child: const ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Profile & Settings'), findsOneWidget);
      expect(find.byType(ProfileHeader), findsOneWidget);
      expect(find.text('Adham Alrefaay'), findsOneWidget);
      expect(find.text('adham@example.com'), findsOneWidget);

      // Activity section
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('My Reports'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Saved Reports'), findsOneWidget);
      expect(find.text('Potential Matches'), findsOneWidget);

      // Account & Preferences
      await tester.scrollUntilVisible(find.text('Theme'), 200);
      expect(find.text('Edit profile'), findsOneWidget);
      expect(find.text('City'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Log out'), 200);
      expect(find.text('Log out'), findsOneWidget);
    });
  });
}
