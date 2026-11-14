import 'package:found_it/core/models/report_type.dart';
import 'package:found_it/features/explore/domain/area_entity.dart';
import 'package:found_it/features/explore/domain/category_entity.dart';
import 'package:found_it/features/explore/domain/city_entity.dart';
import 'package:found_it/features/explore/domain/report_entity.dart';

/// The Explore feature's gateway to the backend.
///
/// Implemented in the data layer; the presentation layer only sees this
/// interface through the use cases.
abstract interface class ExploreRepository {
  /// Reports in [cityId] that match the query and filters, newest first.
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
  });

  /// All active categories, ordered like the database.
  Future<List<CategoryEntity>> getCategories();

  /// The areas of [cityId], ordered for the active [lang] (`ar` or `en`).
  Future<List<AreaEntity>> getCityAreas({
    required String cityId,
    String lang = 'en',
  });

  /// The city of the logged-in user.
  Future<CityEntity> getCityById(String cityId);
}
