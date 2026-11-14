import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/core/constants/storage_keys.dart';
import 'package:found_it/core/models/report_type.dart';
import 'package:found_it/features/explore/data/models/area_model.dart';
import 'package:found_it/features/explore/data/models/category_model.dart';
import 'package:found_it/features/explore/data/models/city_model.dart';
import 'package:found_it/features/explore/data/models/report_model.dart';

/// All Supabase access for Explore lives here. Cubits and screens never
/// import `supabase_flutter`.
abstract interface class ExploreRemoteDataSource {
  Future<CityModel> getCurrentCity();

  Future<List<ReportModel>> searchReports({
    required String cityId,
    String? query,
    ReportType? type,
    List<String>? categoryIds,
    List<String>? areaIds,
    String? dateFrom,
    String? dateTo,
    int limit = 20,
    int offset = 0,
  });

  Future<List<CategoryModel>> getCategories();

  Future<List<AreaModel>> getCityAreas({
    required String cityId,
    required String lang,
  });
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {
  const ExploreRemoteDataSourceImpl(this._supabase, this._prefs);

  final SupabaseClient _supabase;
  final SharedPreferences _prefs;

  @override
  Future<CityModel> getCurrentCity() async {
    final savedCityId = _prefs.getString(StorageKeys.selectedCity);
    if (savedCityId != null && savedCityId.isNotEmpty) {
      final saved = await _supabase
          .from('cities')
          .select('id, name_en, name_ar')
          .eq('id', savedCityId)
          .maybeSingle();
      if (saved != null) return CityModel.fromJson(saved);
    }

    final cairo = await _supabase
        .from('cities')
        .select('id, name_en, name_ar')
        .eq('name_en', 'Cairo')
        .single();
    return CityModel.fromJson(cairo);
  }

  @override
  Future<List<ReportModel>> searchReports({
    required String cityId,
    String? query,
    ReportType? type,
    List<String>? categoryIds,
    List<String>? areaIds,
    String? dateFrom,
    String? dateTo,
    int limit = 20,
    int offset = 0,
  }) async {
    final rows = await _supabase.rpc(
      'search_reports',
      params: {
        'p_city_id': cityId,
        'p_query': (query == null || query.trim().isEmpty)
            ? null
            : query.trim(),
        'p_type': type?.dbValue,
        'p_category_ids': (categoryIds == null || categoryIds.isEmpty)
            ? null
            : categoryIds,
        'p_area_ids': (areaIds == null || areaIds.isEmpty) ? null : areaIds,
        'p_date_from': dateFrom,
        'p_date_to': dateTo,
        'p_limit': limit,
        'p_offset': offset,
      },
    );

    return (rows as List<dynamic>)
        .map((row) => ReportModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final rows = await _supabase
        .from('categories')
        .select()
        .order('sort_order');
    return (rows as List<dynamic>)
        .map((row) => CategoryModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AreaModel>> getCityAreas({
    required String cityId,
    required String lang,
  }) async {
    final rows = await _supabase.rpc(
      'get_city_areas',
      params: {
        'p_city_id': cityId,
        'p_lang': lang.startsWith('ar') ? 'ar' : 'en',
      },
    );
    return (rows as List<dynamic>)
        .map((row) => AreaModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}
