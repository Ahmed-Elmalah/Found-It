import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/home_report_model.dart';

abstract interface class HomeRemoteDataSource {
  Future<List<HomeReportModel>> getHomeFeed({
    required String cityId,
    String? type = 'found',
    int limit = 20,
    int offset = 0,
  });
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  const HomeRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<HomeReportModel>> getHomeFeed({
    required String cityId,
    String? type = 'found',
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client.rpc(
      'get_home_feed',
      params: {
        'p_city_id': cityId,
        'p_type': type,
        'p_limit': limit,
        'p_offset': offset,
      },
    );

    return (response as List<dynamic>)
        .map((row) => HomeReportModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}
