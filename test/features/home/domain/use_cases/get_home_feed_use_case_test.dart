import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/features/home/domain/entities/home_report_item.dart';
import 'package:found_it/features/home/domain/repositories/home_repository.dart';
import 'package:found_it/features/home/domain/use_cases/get_home_feed_use_case.dart';

class _FakeHomeRepository implements HomeRepository {
  List<HomeReportItem> reportsToReturn = const [];
  String? lastCityId;
  String? lastType;

  @override
  Future<List<HomeReportItem>> getHomeFeed({
    required String cityId,
    String? type = 'found',
    int limit = 20,
    int offset = 0,
  }) async {
    lastCityId = cityId;
    lastType = type;
    return reportsToReturn;
  }
}

void main() {
  group('GetHomeFeedUseCase', () {
    late _FakeHomeRepository repo;
    late GetHomeFeedUseCase useCase;

    setUp(() {
      repo = _FakeHomeRepository();
      useCase = GetHomeFeedUseCase(repo);
    });

    test('calls repository with correct parameters and returns reports', () async {
      final tReports = [
        HomeReportItem(
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

      repo.reportsToReturn = tReports;

      final result = await useCase(cityId: 'city-cairo', type: 'found');

      expect(result, tReports);
      expect(repo.lastCityId, 'city-cairo');
      expect(repo.lastType, 'found');
    });
  });
}
