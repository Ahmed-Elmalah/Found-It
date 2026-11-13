import '../entities/home_report_item.dart';

abstract interface class HomeRepository {
  Future<List<HomeReportItem>> getHomeFeed({
    required String cityId,
    String? type = 'found',
    int limit = 20,
    int offset = 0,
  });
}
