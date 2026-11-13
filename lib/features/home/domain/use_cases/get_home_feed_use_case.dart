import '../entities/home_report_item.dart';
import '../repositories/home_repository.dart';

class GetHomeFeedUseCase {
  const GetHomeFeedUseCase(this._repository);

  final HomeRepository _repository;

  Future<List<HomeReportItem>> call({
    required String cityId,
    String? type = 'found',
    int limit = 20,
    int offset = 0,
  }) {
    return _repository.getHomeFeed(
      cityId: cityId,
      type: type,
      limit: limit,
      offset: offset,
    );
  }
}
