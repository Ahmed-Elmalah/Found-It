import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/profile/domain/entities/city_entity.dart';
import 'package:found_it/features/profile/domain/entities/user_profile_entity.dart';
import 'package:found_it/features/profile/domain/repositories/profile_repository.dart';
import 'package:found_it/features/profile/domain/use_cases/get_active_cities_use_case.dart';
import 'package:found_it/features/profile/domain/use_cases/get_profile_use_case.dart';
import 'package:found_it/features/profile/domain/use_cases/set_my_city_use_case.dart';
import 'package:found_it/features/profile/domain/use_cases/update_profile_use_case.dart';
import 'package:found_it/features/profile/view/cubit/profile_cubit.dart';
import 'package:found_it/features/profile/view/cubit/profile_state.dart';

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
    if (shouldFailLoad) throw Exception('Profile error');
    return profile;
  }

  @override
  Future<List<CityEntity>> getActiveCities() async {
    if (shouldFailLoad) throw Exception('Cities error');
    return cities;
  }

  @override
  Future<void> updateProfile({
    required String fullName,
    String? phone,
    String? address,
  }) async {
    if (shouldFailUpdate) throw Exception('Update error');
    lastUpdatedName = fullName;
    profile = profile.copyWith(fullName: fullName, phone: phone, address: address);
  }

  @override
  Future<void> setMyCity(String cityId) async {
    if (shouldFailChangeCity) throw Exception('City error');
    lastUpdatedCity = cityId;
    profile = profile.copyWith(cityId: cityId);
  }
}

void main() {
  group('ProfileCubit', () {
    late _FakeProfileRepo repo;
    late ProfileCubit cubit;

    setUp(() {
      repo = _FakeProfileRepo();
      cubit = ProfileCubit(
        GetProfileUseCase(repo),
        UpdateProfileUseCase(repo),
        SetMyCityUseCase(repo),
        GetActiveCitiesUseCase(repo),
      );
    });

    tearDown(() => cubit.close());

    test('initial state has initial status', () {
      expect(cubit.state.status, ProfileStatus.initial);
      expect(cubit.state.profile, isNull);
      expect(cubit.state.activeCities, isEmpty);
    });

    test('loadProfile loads profile and active cities successfully', () async {
      await cubit.loadProfile();

      expect(cubit.state.status, ProfileStatus.success);
      expect(cubit.state.profile?.fullName, 'Adham Alrefaay');
      expect(cubit.state.activeCities.length, 2);
    });

    test('loadProfile emits failure on error', () async {
      repo.shouldFailLoad = true;

      await cubit.loadProfile();

      expect(cubit.state.status, ProfileStatus.failure);
      expect(cubit.state.errorMessage, isNotNull);
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

    test('updateProfile returns false on error', () async {
      await cubit.loadProfile();
      repo.shouldFailUpdate = true;

      final success = await cubit.updateProfile(fullName: 'Fail');

      expect(success, isFalse);
      expect(cubit.state.isUpdating, isFalse);
      expect(cubit.state.errorMessage, contains('Update error'));
    });

    test('changeCity updates city and refreshes profile', () async {
      await cubit.loadProfile();

      final success = await cubit.changeCity('city_alex');

      expect(success, isTrue);
      expect(repo.lastUpdatedCity, 'city_alex');
      expect(cubit.state.profile?.cityId, 'city_alex');
    });

    test('changeCity returns false on error', () async {
      await cubit.loadProfile();
      repo.shouldFailChangeCity = true;

      final success = await cubit.changeCity('city_alex');

      expect(success, isFalse);
      expect(cubit.state.isUpdating, isFalse);
      expect(cubit.state.errorMessage, contains('City error'));
    });
  });
}
