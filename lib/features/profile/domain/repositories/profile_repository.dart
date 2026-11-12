import 'package:found_it/features/profile/domain/entities/city_entity.dart';
import 'package:found_it/features/profile/domain/entities/user_profile_entity.dart';

abstract interface class ProfileRepository {
  Future<UserProfileEntity> getMyProfile();

  Future<void> updateProfile({
    required String fullName,
    String? phone,
    String? address,
  });

  Future<void> setMyCity(String cityId);

  Future<List<CityEntity>> getActiveCities();

  Future<void> logout();
}
