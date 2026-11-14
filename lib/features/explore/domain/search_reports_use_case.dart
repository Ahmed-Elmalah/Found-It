import 'package:found_it/core/models/report_type.dart';
import 'package:found_it/features/explore/domain/explore_repository.dart';
import 'package:found_it/features/explore/domain/report_entity.dart';

class SearchReportsUseCase {
  const SearchReportsUseCase(this._repository);

  final ExploreRepository _repository;

  Future<List<ReportEntity>> call({
    required String cityId,
    String? query,
    ReportType? type,
    List<String>? categoryIds,
    List<String>? areaIds,
    String? dateFrom,
    String? dateTo,
    int limit = 20,
    int offset = 0,
  }) {
    return _repository.searchReports(
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
  }
}
