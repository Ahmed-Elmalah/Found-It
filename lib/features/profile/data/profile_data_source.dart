import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/features/profile/data/models/city_model.dart';
import 'package:found_it/features/profile/data/models/user_profile_model.dart';

abstract interface class ProfileDataSource {
  Future<UserProfileModel> getMyProfile();

  Future<void> updateProfile({
    required String fullName,
    String? phone,
    String? address,
  });

  Future<void> setMyCity(String cityId);

  Future<List<CityModel>> getActiveCities();

  Future<void> logout();
}

class ProfileDataSourceImpl implements ProfileDataSource {
  const ProfileDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<UserProfileModel> getMyProfile() async {
    final response = await _client.rpc('get_my_profile').single();
    return UserProfileModel.fromJson(response);
  }

  @override
  Future<void> updateProfile({
    required String fullName,
    String? phone,
    String? address,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthApiException('User not authenticated');
    }

    final data = <String, dynamic>{
      'full_name': fullName.trim(),
      if (phone != null) 'phone': phone.trim(),
      if (address != null) 'address': address.trim(),
    };

    await _client.from('profiles').update(data).eq('id', userId);
  }

  @override
  Future<void> setMyCity(String cityId) async {
    await _client.rpc('set_my_city', params: {'p_city_id': cityId});
  }

  @override
  Future<List<CityModel>> getActiveCities() async {
    final response = await _client
        .from('cities')
        .select()
        .eq('is_active', true)
        .order('sort_order');
    final list = response as List<dynamic>;
    return list
        .map((row) => CityModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
