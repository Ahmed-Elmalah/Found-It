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
      profileCubit = ProfileCubit(
        GetProfileUseCase(profileRepo),
        UpdateProfileUseCase(profileRepo),
        SetMyCityUseCase(profileRepo),
        GetActiveCitiesUseCase(profileRepo),
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
      expect(find.text('Edit profile'), findsOneWidget);
      expect(find.text('My Reports'), findsOneWidget);
      expect(find.text('City'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Log out'), 200);
      expect(find.text('Log out'), findsOneWidget);
    });
  });
}
