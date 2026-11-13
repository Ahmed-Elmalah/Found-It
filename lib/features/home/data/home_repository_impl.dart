import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/home_failure.dart';
import '../domain/entities/home_report_item.dart';
import '../domain/repositories/home_repository.dart';
import 'home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({
    required this.remoteDataSource,
  });

  final HomeRemoteDataSource remoteDataSource;

  @override
  Future<List<HomeReportItem>> getHomeFeed({
    required String cityId,
    String? type = 'found',
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      return await remoteDataSource.getHomeFeed(
        cityId: cityId,
        type: type,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      throw _mapError(e);
    }
  }

  HomeFailure _mapError(Object error) {
    if (error is HomeFailure) return error;

    if (error is PostgrestException) {
      return HomeFailure(HomeFailureType.server, error.message);
    }

    if (error is AuthRetryableFetchException || error is TimeoutException) {
      return const HomeFailure(HomeFailureType.network);
    }

    final typeName = error.runtimeType.toString();
    if (typeName.contains('Socket') || typeName.contains('ClientException')) {
      return const HomeFailure(HomeFailureType.network);
    }

    return HomeFailure(HomeFailureType.unknown, error.toString());
  }
}
