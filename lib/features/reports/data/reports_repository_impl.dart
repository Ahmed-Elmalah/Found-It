import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/core/constants/storage_keys.dart';
import 'package:found_it/features/reports/data/reports_remote_data_source.dart';
import 'package:found_it/features/reports/domain/entities/area_entity.dart';
import 'package:found_it/features/reports/domain/entities/category_entity.dart';
import 'package:found_it/features/reports/domain/entities/create_report_params.dart';
import 'package:found_it/features/reports/domain/entities/report_counts_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_failure.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;
  final SharedPreferences prefs;

  const ReportsRepositoryImpl({
    required this.remoteDataSource,
    required this.prefs,
  });

  @override
  Future<List<ReportEntity>> getMyReports({String? status}) async {
    try {
      return await remoteDataSource.getMyReports(status: status);
    } catch (e) {
      throw _mapFailure(e);
    }
  }

  @override
  Future<ReportCountsEntity> getMyReportsCounts() async {
    try {
      return await remoteDataSource.getMyReportsCounts();
    } catch (e) {
      throw _mapFailure(e);
    }
  }

  @override
  Future<ReportEntity> updateReport({
    required String reportId,
    String? title,
    String? description,
    String? type,
    String? categoryId,
    String? areaId,
    DateTime? itemDate,
  }) async {
    try {
      return await remoteDataSource.updateReport(
        reportId: reportId,
        title: title,
        description: description,
        type: type,
        categoryId: categoryId,
        areaId: areaId,
        itemDate: itemDate,
      );
    } catch (e) {
      throw _mapFailure(e);
    }
  }

  @override
  Future<void> softDeleteReport(String reportId) async {
    try {
      await remoteDataSource.softDeleteReport(reportId);
    } catch (e) {
      throw _mapFailure(e);
    }
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    try {
      return await remoteDataSource.getCategories();
    } catch (e) {
      throw _mapFailure(e);
    }
  }

  @override
  Future<List<AreaEntity>> getCityAreas({
    required String cityId,
    required String lang,
  }) async {
    try {
      return await remoteDataSource.getCityAreas(
        cityId: cityId,
        lang: lang,
      );
    } catch (e) {
      throw _mapFailure(e);
    }
  }

  @override
  Future<String> getSelectedCityId() async {
    try {
      final saved = prefs.getString(StorageKeys.selectedCity);
      if (saved != null && saved.isNotEmpty) return saved;

      final userCity = await remoteDataSource.getUserCityId();
      if (userCity != null && userCity.isNotEmpty) return userCity;

      return await remoteDataSource.getDefaultCityId();
    } catch (e) {
      throw _mapFailure(e);
    }
  }

  @override
  Future<String> createReport(CreateReportParams params) async {
    final userId = remoteDataSource.currentUserId();
    if (userId == null || userId.isEmpty) {
      throw const ReportFailure(ReportFailureType.notLoggedIn);
    }

    final uploadedPaths = <String>[];
    final imageUrls = <String>[];

    try {
      for (var i = 0; i < params.images.length; i++) {
        final uploaded = await remoteDataSource.uploadPhoto(
          image: params.images[i],
          userId: userId,
          index: i,
        );
        uploadedPaths.add(uploaded.path);
        imageUrls.add(uploaded.publicUrl);
      }

      return await remoteDataSource.createReport(
        params: params,
        imageUrls: imageUrls,
      );
    } catch (e) {
      if (uploadedPaths.isNotEmpty) {
        try {
          await remoteDataSource.deletePhotos(uploadedPaths);
        } catch (_) {
          // ignore cleanup errors
        }
      }
      throw _mapFailure(e);
    }
  }

  ReportFailure _mapFailure(Object error) {
    if (error is ReportFailure) return error;

    if (error is PostgrestException) {
      if (error.code == '23514' || error.code == '23503') {
        return const ReportFailure(ReportFailureType.invalidData);
      }
      final msg = error.message.toLowerCase();
      if (msg.contains('invalid') || msg.contains('not found')) {
        return const ReportFailure(ReportFailureType.invalidData);
      }
    }

    if (error is AuthRetryableFetchException || error is TimeoutException) {
      return const ReportFailure(ReportFailureType.network);
    }

    final typeName = error.runtimeType.toString();
    if (typeName.contains('Socket') || typeName.contains('ClientException')) {
      return const ReportFailure(ReportFailureType.network);
    }

    return const ReportFailure(ReportFailureType.unknown);
  }
}
