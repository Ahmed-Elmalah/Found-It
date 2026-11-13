import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/features/city/data/city_model.dart';

abstract interface class CityRemoteDataSource {
  Future<List<CityModel>> getActiveCities();
  Future<void> setMyCity(String cityId);
}

class CityRemoteDataSourceImpl implements CityRemoteDataSource {
  const CityRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<CityModel>> getActiveCities() async {
    final response = await _client
        .from('cities')
        .select('id, name_en, name_ar, sort_order')
        .eq('is_active', true)
        .order('sort_order', ascending: true);

    return (response as List<dynamic>)
        .map((row) => CityModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> setMyCity(String cityId) async {
    await _client.rpc('set_my_city', params: {'p_city_id': cityId});
  }
}
