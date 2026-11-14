import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/features/home/data/home_remote_data_source.dart';
import 'package:found_it/features/home/data/home_repository_impl.dart';
import 'package:found_it/features/home/data/models/home_report_model.dart';
import 'package:found_it/features/home/domain/entities/home_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeHomeRemoteDataSource implements HomeRemoteDataSource {
  List<HomeReportModel> itemsToReturn = const [];
  Object? errorToThrow;

  @override
  Future<List<HomeReportModel>> getHomeFeed({
    required String cityId,
    String? type = 'found',
    int limit = 20,
    int offset = 0,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    return itemsToReturn;
  }
}

void main() {
  group('HomeRepositoryImpl', () {
    late _FakeHomeRemoteDataSource remoteDataSource;
    late HomeRepositoryImpl repository;

    setUp(() {
      remoteDataSource = _FakeHomeRemoteDataSource();
      repository = HomeRepositoryImpl(remoteDataSource: remoteDataSource);
    });

    test('returns reports when remoteDataSource succeeds', () async {
      final tReports = [
        HomeReportModel(
          id: 'rep-1',
          refCode: 'RPT-1',
          title: 'Found Keys',
          type: 'found',
          categoryName: 'Keys',
          categoryIcon: 'key',
          areaName: 'Maadi',
          cityName: 'Cairo',
          itemDate: DateTime.now(),
          images: const [],
          status: 'active',
          isMine: false,
          createdAt: DateTime.now(),
        ),
      ];

      remoteDataSource.itemsToReturn = tReports;

      final result = await repository.getHomeFeed(cityId: 'cairo');

      expect(result, tReports);
    });

    test('maps PostgrestException to HomeFailureType.server', () async {
      remoteDataSource.errorToThrow = const PostgrestException(
        message: 'function get_home_feed does not exist',
      );

      expect(
        () => repository.getHomeFeed(cityId: 'cairo'),
        throwsA(isA<HomeFailure>().having(
          (f) => f.type,
          'type',
          HomeFailureType.server,
        )),
      );
    });

    test('maps TimeoutException to HomeFailureType.network', () async {
      remoteDataSource.errorToThrow = TimeoutException('network timeout');

      expect(
        () => repository.getHomeFeed(cityId: 'cairo'),
        throwsA(isA<HomeFailure>().having(
          (f) => f.type,
          'type',
          HomeFailureType.network,
        )),
      );
    });
  });
}
