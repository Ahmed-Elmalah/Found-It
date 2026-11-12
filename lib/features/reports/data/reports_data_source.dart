import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/features/reports/data/models/area_model.dart';
import 'package:found_it/features/reports/data/models/category_model.dart';
import 'package:found_it/features/reports/data/models/report_counts_model.dart';
import 'package:found_it/features/reports/data/models/report_model.dart';

abstract interface class ReportsDataSource {
  Future<List<ReportModel>> getMyReports({String? status});

  Future<ReportCountsModel> getMyReportsCounts();

  Future<ReportModel> updateReport({
    required String reportId,
    String? title,
    String? description,
    String? type,
    String? categoryId,
    String? areaId,
    DateTime? itemDate,
  });

  Future<void> softDeleteReport(String reportId);

  Future<List<CategoryModel>> getCategories();

  Future<List<AreaModel>> getCityAreas({
    required String cityId,
    String? lang,
  });
}

class ReportsDataSourceImpl implements ReportsDataSource {
  const ReportsDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<ReportModel>> getMyReports({String? status}) async {
    final response = await _client.rpc(
      'get_my_reports',
      params: {
        if (status != null && status.isNotEmpty && status != 'all')
          'p_status': status,
      },
    );
    final list = response as List<dynamic>;
    return list
        .map((row) => ReportModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ReportCountsModel> getMyReportsCounts() async {
    final response = await _client.rpc('get_my_reports_counts').single();
    return ReportCountsModel.fromJson(response);
  }

  @override
  Future<ReportModel> updateReport({
    required String reportId,
    String? title,
    String? description,
    String? type,
    String? categoryId,
    String? areaId,
    DateTime? itemDate,
  }) async {
    final params = <String, dynamic>{
      'p_report_id': reportId,
      if (title != null) 'p_title': title.trim(),
      if (description != null) 'p_description': description.trim(),
      ?'p_type': type,
      ?'p_category_id': categoryId,
      ?'p_area_id': areaId,
      if (itemDate != null)
        'p_item_date': itemDate.toIso8601String().split('T').first,
    };

    final response = await _client.rpc('update_report', params: params).single();
    return ReportModel.fromJson(response);
  }

  @override
  Future<void> softDeleteReport(String reportId) async {
    await _client.rpc('soft_delete_report', params: {'p_report_id': reportId});
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .eq('is_active', true)
        .order('sort_order');
    final list = response as List<dynamic>;
    return list
        .map((row) => CategoryModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AreaModel>> getCityAreas({
    required String cityId,
    String? lang,
  }) async {
    final response = await _client.rpc('get_city_areas', params: {
      'p_city_id': cityId,
      if (lang != null) 'p_lang': lang,
    });
    final list = response as List<dynamic>;
    return list
        .map((row) => AreaModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}
