import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/profile/domain/entities/city_entity.dart';
import 'package:found_it/features/profile/domain/entities/profile_failure.dart';
import 'package:found_it/features/profile/domain/entities/user_profile_entity.dart';
import 'package:found_it/features/profile/domain/repositories/profile_repository.dart';
import 'package:found_it/features/profile/domain/use_cases/get_active_cities_use_case.dart';
import 'package:found_it/features/profile/domain/use_cases/get_profile_use_case.dart';
import 'package:found_it/features/profile/domain/use_cases/set_my_city_use_case.dart';
import 'package:found_it/features/profile/domain/use_cases/update_profile_use_case.dart';
import 'package:found_it/features/profile/view/cubit/profile_cubit.dart';
import 'package:found_it/features/profile/view/cubit/profile_state.dart';
import 'package:found_it/features/reports/domain/entities/area_entity.dart';
import 'package:found_it/features/reports/domain/entities/category_entity.dart';
import 'package:found_it/features/reports/domain/entities/create_report_params.dart';
import 'package:found_it/features/reports/domain/entities/report_counts_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_entity.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';
import 'package:found_it/features/reports/domain/use_cases/get_my_reports_counts_use_case.dart';

class _FakeProfileRepo implements ProfileRepository {
  bool shouldFailLoad = false;
  bool shouldFailUpdate = false;
  bool shouldFailChangeCity = false;

  UserProfileEntity profile = UserProfileEntity(
    id: 'user_1',
    email: 'adham@example.com',
    fullName: 'Adham Alrefaay',
    phone: '01012345678',
    address: 'Cairo, Egypt',
    role: 'user',
    cityId: 'city_cairo',
    cityNameEn: 'Cairo',
    cityNameAr: 'القاهرة',
    createdAt: DateTime(2026, 11, 1),
  );

  final cities = const [
    CityEntity(id: 'city_cairo', nameEn: 'Cairo', nameAr: 'القاهرة', sortOrder: 1),
    CityEntity(id: 'city_alex', nameEn: 'Alexandria', nameAr: 'الإسكندرية', sortOrder: 2),
  ];

  String? lastUpdatedName;
  String? lastUpdatedCity;

  @override
  Future<UserProfileEntity> getMyProfile() async {
    if (shouldFailLoad) throw const ProfileFailure(ProfileFailureType.network);
    return profile;
  }

  @override
  Future<List<CityEntity>> getActiveCities() async {
    if (shouldFailLoad) throw const ProfileFailure(ProfileFailureType.network);
    return cities;
  }

  @override
  Future<void> updateProfile({
    required String fullName,
    String? phone,
    String? address,
  }) async {
    if (shouldFailUpdate) throw const ProfileFailure(ProfileFailureType.unknown);
    lastUpdatedName = fullName;
    profile = profile.copyWith(fullName: fullName, phone: phone, address: address);
  }

  @override
  Future<void> setMyCity(String cityId) async {
    if (shouldFailChangeCity) throw const ProfileFailure(ProfileFailureType.unknown);
    lastUpdatedCity = cityId;
    profile = profile.copyWith(cityId: cityId);
  }
}

class _FakeReportsRepoForProfile implements ReportsRepository {
  @override
  Future<ReportCountsEntity> getMyReportsCounts() async => const ReportCountsEntity(
        total: 5,
        active: 3,
        matching: 1,
        recovered: 1,
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

void main() {
  group('ProfileCubit', () {
    late _FakeProfileRepo repo;
    late _FakeReportsRepoForProfile reportsRepo;
    late ProfileCubit cubit;

    setUp(() {
      repo = _FakeProfileRepo();
      reportsRepo = _FakeReportsRepoForProfile();
      cubit = ProfileCubit(
        GetProfileUseCase(repo),
        UpdateProfileUseCase(repo),
        SetMyCityUseCase(repo),
        GetActiveCitiesUseCase(repo),
        GetMyReportsCountsUseCase(reportsRepo),
      );
    });

    tearDown(() => cubit.close());

    test('initial state has initial status', () {
      expect(cubit.state.status, ProfileStatus.initial);
      expect(cubit.state.profile, isNull);
      expect(cubit.state.activeCities, isEmpty);
      expect(cubit.state.reportsCount, 0);
    });

    test('loadProfile loads profile, active cities, and reports count successfully', () async {
      await cubit.loadProfile();

      expect(cubit.state.status, ProfileStatus.success);
      expect(cubit.state.profile?.fullName, 'Adham Alrefaay');
      expect(cubit.state.activeCities.length, 2);
      expect(cubit.state.reportsCount, 5);
    });

    test('loadProfile emits failure on error without string error', () async {
      repo.shouldFailLoad = true;

      await cubit.loadProfile();

      expect(cubit.state.status, ProfileStatus.failure);
      expect(cubit.state.failure, ProfileFailureType.network);
    });

    test('updateProfile updates profile and refreshes state', () async {
      await cubit.loadProfile();

      final success = await cubit.updateProfile(
        fullName: 'Adham New',
        phone: '01099999999',
        address: 'New Cairo',
      );

      expect(success, isTrue);
      expect(repo.lastUpdatedName, 'Adham New');
      expect(cubit.state.profile?.fullName, 'Adham New');
      expect(cubit.state.isUpdating, isFalse);
    });

    test('updateProfile returns false on error and sets typed failure', () async {
      await cubit.loadProfile();
      repo.shouldFailUpdate = true;

      final success = await cubit.updateProfile(fullName: 'Fail');

      expect(success, isFalse);
      expect(cubit.state.isUpdating, isFalse);
      expect(cubit.state.failure, ProfileFailureType.unknown);
    });

    test('changeCity updates city and refreshes profile', () async {
      await cubit.loadProfile();

      final success = await cubit.changeCity('city_alex');

      expect(success, isTrue);
      expect(repo.lastUpdatedCity, 'city_alex');
      expect(cubit.state.profile?.cityId, 'city_alex');
    });

    test('changeCity returns false on error and sets typed failure', () async {
      await cubit.loadProfile();
      repo.shouldFailChangeCity = true;

      final success = await cubit.changeCity('city_alex');

      expect(success, isFalse);
      expect(cubit.state.isUpdating, isFalse);
      expect(cubit.state.failure, ProfileFailureType.unknown);
    });
  });
}
