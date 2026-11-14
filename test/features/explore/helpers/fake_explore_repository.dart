import 'package:found_it/core/models/report_status.dart';
import 'package:found_it/core/models/report_type.dart';
import 'package:found_it/features/explore/domain/area_entity.dart';
import 'package:found_it/features/explore/domain/category_entity.dart';
import 'package:found_it/features/explore/domain/city_entity.dart';
import 'package:found_it/features/explore/domain/explore_failure.dart';
import 'package:found_it/features/explore/domain/explore_repository.dart';
import 'package:found_it/features/explore/domain/report_entity.dart';

/// Hand-made fake (no mockito / mocktail) used by the Cubit and widget tests.
class FakeExploreRepository implements ExploreRepository {
  FakeExploreRepository({List<ReportEntity>? reports})
    : reports = reports ?? defaultReports;

  final List<ReportEntity> reports;

  bool shouldFail = false;

  int searchCalls = 0;
  String? lastQuery;
  ReportType? lastType;
  List<String>? lastCategoryIds;
  List<String>? lastAreaIds;
  String? lastDateFrom;
  String? lastDateTo;

  static final CityEntity city = const CityEntity(
    id: 'city-cairo',
    nameEn: 'Cairo',
    nameAr: 'القاهرة',
  );

  static const List<CategoryEntity> categories = [
    CategoryEntity(
      id: 'cat-electronics',
      nameEn: 'Electronics',
      nameAr: 'إلكترونيات',
      icon: 'devices',
    ),
    CategoryEntity(
      id: 'cat-wallets',
      nameEn: 'Wallets',
      nameAr: 'محافظ',
      icon: 'account_balance_wallet',
    ),
    CategoryEntity(
      id: 'cat-bags',
      nameEn: 'Bags',
      nameAr: 'حقائب',
      icon: 'shopping_bag',
    ),
  ];

  static const List<AreaEntity> areas = [
    AreaEntity(
      id: 'area-zamalek',
      cityId: 'city-cairo',
      nameEn: 'Zamalek',
      nameAr: 'الزمالك',
    ),
    AreaEntity(
      id: 'area-maadi',
      cityId: 'city-cairo',
      nameEn: 'Maadi',
      nameAr: 'المعادي',
    ),
  ];

  static final List<ReportEntity> defaultReports = [
    ReportEntity(
      id: 'report-1',
      refCode: 'RPT-1001',
      title: 'AirPods Pro, white case',
      description: 'Left them on the metro line 3.',
      categoryId: 'cat-electronics',
      type: ReportType.lost,
      status: ReportStatus.active,
      categoryNameEn: 'Electronics',
      categoryNameAr: 'إلكترونيات',
      cityNameEn: 'Cairo',
      cityNameAr: 'القاهرة',
      areaNameEn: 'Zamalek',
      areaNameAr: 'الزمالك',
      itemDate: DateTime(2026, 11, 4),
      images: const [],
      isMine: false,
    ),
    ReportEntity(
      id: 'report-2',
      refCode: 'RPT-1002',
      title: 'Black leather wallet',
      description: 'Found near the Maadi metro station.',
      categoryId: 'cat-wallets',
      type: ReportType.found,
      status: ReportStatus.active,
      categoryNameEn: 'Wallets',
      categoryNameAr: 'محافظ',
      cityNameEn: 'Cairo',
      cityNameAr: 'القاهرة',
      areaNameEn: 'Maadi',
      areaNameAr: 'المعادي',
      itemDate: DateTime(2026, 11, 3),
      images: const [],
      isMine: false,
    ),
    ReportEntity(
      id: 'report-3',
      refCode: 'RPT-1003',
      title: 'Brown leather handbag',
      description: 'Found at City Stars.',
      categoryId: 'cat-bags',
      type: ReportType.found,
      status: ReportStatus.active,
      categoryNameEn: 'Bags',
      categoryNameAr: 'حقائب',
      cityNameEn: 'Cairo',
      cityNameAr: 'القاهرة',
      areaNameEn: 'Nasr City',
      areaNameAr: 'مدينة نصر',
      itemDate: DateTime(2026, 11, 2),
      images: const [],
      isMine: false,
    ),
  ];

  String? lastAreaLang;
  String? lastCityId;

  void resetRecording() {
    searchCalls = 0;
    lastQuery = null;
    lastType = null;
    lastCategoryIds = null;
    lastAreaIds = null;
    lastDateFrom = null;
    lastDateTo = null;
    lastAreaLang = null;
    lastCityId = null;
  }

  @override
  Future<CityEntity> getCityById(String cityId) async {
    lastCityId = cityId;
    return city;
  }

  @override
  Future<List<CategoryEntity>> getCategories() async => categories;

  @override
  Future<List<AreaEntity>> getCityAreas({
    required String cityId,
    String lang = 'en',
  }) async {
    lastAreaLang = lang;
    return areas;
  }

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
    searchCalls++;
    lastQuery = query;
    lastType = type;
    lastCategoryIds = categoryIds;
    lastAreaIds = areaIds;
    lastDateFrom = dateFrom;
    lastDateTo = dateTo;

    if (shouldFail) {
      throw const ExploreFailure(ExploreFailureType.unknown);
    }

    var results = reports;

    if (query != null && query.trim().isNotEmpty) {
      final needle = query.trim().toLowerCase();
      results = results
          .where(
            (report) =>
                report.title.toLowerCase().contains(needle) ||
                (report.description ?? '').toLowerCase().contains(needle),
          )
          .toList();
    }

    if (type != null) {
      results = results.where((report) => report.type == type).toList();
    }

    if (categoryIds != null && categoryIds.isNotEmpty) {
      results = results
          .where((report) => categoryIds.contains(report.categoryId))
          .toList();
    }

    if (dateFrom != null) {
      results = results
          .where(
            (report) => !report.itemDate.isBefore(DateTime.parse(dateFrom)),
          )
          .toList();
    }

    if (dateTo != null) {
      results = results
          .where((report) => !report.itemDate.isAfter(DateTime.parse(dateTo)))
          .toList();
    }

    return results;
  }
}
