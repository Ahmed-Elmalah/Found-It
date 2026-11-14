import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/core/models/report_type.dart';
import 'package:found_it/features/explore/data/explore_remote_data_source.dart';
import 'package:found_it/features/explore/domain/area_entity.dart';
import 'package:found_it/features/explore/domain/category_entity.dart';
import 'package:found_it/features/explore/domain/city_entity.dart';
import 'package:found_it/features/explore/domain/explore_failure.dart';
import 'package:found_it/features/explore/domain/explore_repository.dart';
import 'package:found_it/features/explore/domain/report_entity.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  const ExploreRepositoryImpl({required this.remoteDataSource});

  final ExploreRemoteDataSource remoteDataSource;

  @override
  Future<List<ReportEntity>> searchReports({
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
    try {
      final rows = await remoteDataSource.searchReports(
        cityId: cityId,
        query: query,
        type: type,
        categoryIds: categoryIds,
        areaIds: areaIds,
        dateFrom: dateFrom,
        dateTo: dateTo,
        limit: limit,
        offset: offset,
      );
      return rows.map((row) => row.toEntity()).toList();
    } catch (error) {
      throw _mapFailure(error);
    }
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    try {
      return await remoteDataSource.getCategories();
    } catch (error) {
      throw _mapFailure(error);
    }
  }

  @override
  Future<List<AreaEntity>> getCityAreas({
    required String cityId,
    String lang = 'en',
  }) async {
    try {
      return await remoteDataSource.getCityAreas(cityId: cityId, lang: lang);
    } catch (error) {
      throw _mapFailure(error);
    }
  }

  @override
  Future<CityEntity> getCurrentCity() async {
    try {
      return await remoteDataSource.getCurrentCity();
    } catch (error) {
      throw _mapFailure(error);
    }
  }

  ExploreFailure _mapFailure(Object error) {
    if (error is ExploreFailure) return error;

    if (error is PostgrestException) {
      return switch (error.code) {
        '23514' ||
        '23503' => const ExploreFailure(ExploreFailureType.invalidData),
        'P0002' => const ExploreFailure(ExploreFailureType.notFound),
        '42501' => const ExploreFailure(ExploreFailureType.notAllowed),
        _ => const ExploreFailure(ExploreFailureType.unknown),
      };
    }

    if (error is AuthRetryableFetchException || error is TimeoutException) {
      return const ExploreFailure(ExploreFailureType.network);
    }

    final typeName = error.runtimeType.toString();
    if (typeName.contains('Socket') || typeName.contains('ClientException')) {
      return const ExploreFailure(ExploreFailureType.network);
    }

    return const ExploreFailure(ExploreFailureType.unknown);
  }
}
