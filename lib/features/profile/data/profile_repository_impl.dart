import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/features/profile/data/profile_data_source.dart';
import 'package:found_it/features/profile/domain/entities/city_entity.dart';
import 'package:found_it/features/profile/domain/entities/profile_failure.dart';
import 'package:found_it/features/profile/domain/entities/user_profile_entity.dart';
import 'package:found_it/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._dataSource);

  final ProfileDataSource _dataSource;

  @override
  Future<UserProfileEntity> getMyProfile() async {
    try {
      return await _dataSource.getMyProfile();
    } catch (e) {
      throw _mapFailure(e);
    }
  }

  @override
  Future<void> updateProfile({
    required String fullName,
    String? phone,
    String? address,
  }) async {
    try {
      await _dataSource.updateProfile(
        fullName: fullName,
        phone: phone,
        address: address,
      );
    } catch (e) {
      throw _mapFailure(e);
    }
  }

  @override
  Future<void> setMyCity(String cityId) async {
    try {
      await _dataSource.setMyCity(cityId);
    } catch (e) {
      throw _mapFailure(e);
    }
  }

  @override
  Future<List<CityEntity>> getActiveCities() async {
    try {
      return await _dataSource.getActiveCities();
    } catch (e) {
      throw _mapFailure(e);
    }
  }

  ProfileFailure _mapFailure(Object error) {
    if (error is ProfileFailure) return error;
    if (error is AuthRetryableFetchException || error is TimeoutException) {
      return const ProfileFailure(ProfileFailureType.network);
    }
    final msg = error.toString().toLowerCase();
    if (msg.contains('socket') || msg.contains('clientexception') || msg.contains('network')) {
      return const ProfileFailure(ProfileFailureType.network);
    }
    return const ProfileFailure(ProfileFailureType.unknown);
  }
}
