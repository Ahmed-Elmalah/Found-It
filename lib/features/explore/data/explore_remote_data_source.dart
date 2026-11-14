import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/core/models/report_type.dart';
import 'package:found_it/features/explore/data/models/area_model.dart';
import 'package:found_it/features/explore/data/models/category_model.dart';
import 'package:found_it/features/explore/data/models/city_model.dart';
import 'package:found_it/features/explore/data/models/report_model.dart';

/// All Supabase access for Explore lives here. Cubits and screens never
/// import `supabase_flutter`.
abstract interface class ExploreRemoteDataSource {
  Future<CityModel> getCityById(String cityId);

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
    String lang = 'en',
  });
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {
  const ExploreRemoteDataSourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<CityModel> getCityById(String cityId) async {
    final row = await _supabase
        .from('cities')
        .select('id, name_en, name_ar')
        .eq('id', cityId)
        .single();
    return CityModel.fromJson(row);
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
    String lang = 'en',
  }) async {
    final rows = await _supabase.rpc(
      'get_city_areas',
      params: {'p_city_id': cityId, 'p_lang': lang},
    );
    return (rows as List<dynamic>)
        .map((row) => AreaModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}
