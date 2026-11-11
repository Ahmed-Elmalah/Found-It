import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/core/constants/storage_keys.dart';
import 'package:found_it/features/reports/data/reports_remote_data_source.dart';
import 'package:found_it/features/reports/domain/entities/area_entity.dart';
import 'package:found_it/features/reports/domain/entities/category_entity.dart';
import 'package:found_it/features/reports/domain/entities/create_report_params.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;
  final SharedPreferences prefs;
  final SupabaseClient supabase;

  const ReportsRepositoryImpl({
    required this.remoteDataSource,
    required this.prefs,
    required this.supabase,
  });

  @override
  Future<List<CategoryEntity>> getCategories() =>
      remoteDataSource.getCategories();

  @override
  Future<List<AreaEntity>> getCityAreas({
    required String cityId,
    required String lang,
  }) =>
      remoteDataSource.getCityAreas(cityId: cityId, lang: lang);

  @override
  Future<String> getSelectedCityId() async {
    final saved = prefs.getString(StorageKeys.selectedCity);
    if (saved != null && saved.isNotEmpty) return saved;
    return remoteDataSource.getDefaultCityId();
  }

  @override
  Future<String> createReport(CreateReportParams params) async {
    final userId = supabase.auth.currentUser?.id ?? 'anonymous';
    final imageUrls = <String>[];
    for (var i = 0; i < params.images.length; i++) {
      final url = await remoteDataSource.uploadPhoto(
        file: params.images[i],
        userId: userId,
        index: i,
      );
      imageUrls.add(url);
    }

    return remoteDataSource.createReport(
      params: params,
      imageUrls: imageUrls,
    );
  }
}
