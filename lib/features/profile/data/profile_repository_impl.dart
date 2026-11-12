import 'package:found_it/features/profile/data/profile_data_source.dart';
import 'package:found_it/features/profile/domain/entities/city_entity.dart';
import 'package:found_it/features/profile/domain/entities/user_profile_entity.dart';
import 'package:found_it/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._dataSource);

  final ProfileDataSource _dataSource;

  @override
  Future<UserProfileEntity> getMyProfile() {
    return _dataSource.getMyProfile();
  }

  @override
  Future<void> updateProfile({
    required String fullName,
    String? phone,
    String? address,
  }) {
    return _dataSource.updateProfile(
      fullName: fullName,
      phone: phone,
      address: address,
    );
  }

  @override
  Future<void> setMyCity(String cityId) {
    return _dataSource.setMyCity(cityId);
  }

  @override
  Future<List<CityEntity>> getActiveCities() {
    return _dataSource.getActiveCities();
  }

  @override
  Future<void> logout() {
    return _dataSource.logout();
  }
}
