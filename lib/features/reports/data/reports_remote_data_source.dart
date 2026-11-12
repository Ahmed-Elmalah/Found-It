import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/features/reports/data/models/area_model.dart';
import 'package:found_it/features/reports/data/models/category_model.dart';
import 'package:found_it/features/reports/domain/entities/create_report_params.dart';
import 'package:found_it/features/reports/domain/entities/report_image.dart';

class UploadedPhoto {
  final String path;
  final String publicUrl;

  const UploadedPhoto({required this.path, required this.publicUrl});
}

abstract class ReportsRemoteDataSource {
  String? currentUserId();

  Future<List<CategoryModel>> getCategories();

  Future<List<AreaModel>> getCityAreas({
    required String cityId,
    required String lang,
  });

  Future<UploadedPhoto> uploadPhoto({
    required ReportImage image,
    required String userId,
    required int index,
  });

  Future<void> deletePhotos(List<String> paths);

  Future<String> createReport({
    required CreateReportParams params,
    required List<String> imageUrls,
  });

  Future<String> getDefaultCityId();

  Future<String?> getUserCityId();
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final SupabaseClient _supabase;

  const ReportsRemoteDataSourceImpl(this._supabase);

  @override
  String? currentUserId() => _supabase.auth.currentUser?.id;

  @override
  Future<List<CategoryModel>> getCategories() async {
    final res = await _supabase
        .from('categories')
        .select()
        .eq('is_active', true)
        .order('sort_order');
    return (res as List)
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AreaModel>> getCityAreas({
    required String cityId,
    required String lang,
  }) async {
    final res = await _supabase.rpc(
      'get_city_areas',
      params: {
        'p_city_id': cityId,
        'p_lang': lang.startsWith('ar') ? 'ar' : 'en',
      },
    );
    return (res as List)
        .map((e) => AreaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<UploadedPhoto> uploadPhoto({
    required ReportImage image,
    required String userId,
    required int index,
  }) async {
    final ext = image.name.contains('.')
        ? image.name.split('.').last.toLowerCase()
        : 'jpg';
    final path =
        '$userId/${DateTime.now().millisecondsSinceEpoch}_$index.$ext';

    await _supabase.storage.from('report-images').uploadBinary(
          path,
          image.bytes,
          fileOptions: FileOptions(
            contentType: ext == 'png' ? 'image/png' : 'image/jpeg',
          ),
        );

    final publicUrl =
        _supabase.storage.from('report-images').getPublicUrl(path);

    return UploadedPhoto(path: path, publicUrl: publicUrl);
  }

  @override
  Future<void> deletePhotos(List<String> paths) async {
    if (paths.isEmpty) return;
    await _supabase.storage.from('report-images').remove(paths);
  }

  @override
  Future<String> createReport({
    required CreateReportParams params,
    required List<String> imageUrls,
  }) async {
    final dateStr =
        '${params.itemDate.year.toString().padLeft(4, '0')}-${params.itemDate.month.toString().padLeft(2, '0')}-${params.itemDate.day.toString().padLeft(2, '0')}';

    final res = await _supabase.rpc('create_report', params: {
      'p_type': params.type,
      'p_title': params.title,
      'p_category_id': params.categoryId,
      'p_city_id': params.cityId,
      'p_area_id': params.areaId,
      'p_images': imageUrls,
      'p_item_date': dateStr,
      if (params.description != null) 'p_description': params.description,
    }).single();

    return res['ref_code'] as String;
  }

  @override
  Future<String> getDefaultCityId() async {
    final res = await _supabase
        .from('cities')
        .select('id')
        .eq('name_en', 'Cairo')
        .maybeSingle();

    if (res != null && res['id'] != null) {
      return res['id'] as String;
    }
    final first =
        await _supabase.from('cities').select('id').limit(1).maybeSingle();
    final id = first?['id'] as String?;
    if (id == null || id.isEmpty) {
      throw const PostgrestException(message: 'No default city found');
    }
    return id;
  }

  @override
  Future<String?> getUserCityId() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return null;
    try {
      final res = await _supabase
          .from('profiles')
          .select('city_id')
          .eq('id', uid)
          .maybeSingle();
      final cityId = res?['city_id'] as String?;
      if (cityId != null && cityId.isNotEmpty) {
        return cityId;
      }
    } catch (_) {}
    return null;
  }
}
