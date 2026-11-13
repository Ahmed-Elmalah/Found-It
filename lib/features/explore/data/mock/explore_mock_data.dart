import 'package:found_it/core/models/report_status.dart';
import 'package:found_it/core/models/report_type.dart';
import 'package:found_it/features/explore/domain/area_entity.dart';
import 'package:found_it/features/explore/domain/category_entity.dart';
import 'package:found_it/features/explore/domain/city_entity.dart';
import 'package:found_it/features/explore/domain/report_entity.dart';

/// Static data used by the Explore UI until the Supabase layer lands.
///
/// The shapes match the real `cities` / `areas` / `categories` tables and the
/// `report_details` view, so swapping this class for the repository is a
/// one-line change in the screen.
abstract final class ExploreMockData {
  static const CityEntity city = CityEntity(
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
      id: 'cat-keys',
      nameEn: 'Keys',
      nameAr: 'مفاتيح',
      icon: 'key',
    ),
    CategoryEntity(
      id: 'cat-bags',
      nameEn: 'Bags',
      nameAr: 'حقائب',
      icon: 'shopping_bag',
    ),
    CategoryEntity(
      id: 'cat-documents',
      nameEn: 'Documents',
      nameAr: 'مستندات',
      icon: 'description',
    ),
    CategoryEntity(
      id: 'cat-pets',
      nameEn: 'Pets',
      nameAr: 'حيوانات أليفة',
      icon: 'pets',
    ),
    CategoryEntity(
      id: 'cat-other',
      nameEn: 'Other',
      nameAr: 'أخرى',
      icon: 'category',
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
    AreaEntity(
      id: 'area-nasr-city',
      cityId: 'city-cairo',
      nameEn: 'Nasr City',
      nameAr: 'مدينة نصر',
    ),
    AreaEntity(
      id: 'area-other',
      cityId: 'city-cairo',
      nameEn: 'Other',
      nameAr: 'أخرى',
    ),
  ];

  static final List<ReportEntity> reports = [
    ReportEntity(
      id: 'report-1',
      refCode: 'RPT-1001',
      title: 'AirPods Pro, white case',
      description: 'Left them on the metro line 3, white charging case.',
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
      images: const ['https://picsum.photos/seed/foundit-airpods/200/200'],
      isMine: true,
    ),
    ReportEntity(
      id: 'report-2',
      refCode: 'RPT-1002',
      title: 'Black leather wallet',
      description: 'Found near the Maadi metro station, has a bank card.',
      categoryId: 'cat-wallets',
      type: ReportType.found,
      status: ReportStatus.matching,
      categoryNameEn: 'Wallets',
      categoryNameAr: 'محافظ',
      cityNameEn: 'Cairo',
      cityNameAr: 'القاهرة',
      areaNameEn: 'Maadi',
      areaNameAr: 'المعادي',
      itemDate: DateTime(2026, 11, 3),
      images: const ['https://picsum.photos/seed/foundit-wallet/200/200'],
      isMine: false,
    ),
    ReportEntity(
      id: 'report-3',
      refCode: 'RPT-1003',
      title: 'House keys with blue tag',
      description: 'Three keys on a small blue plastic tag.',
      categoryId: 'cat-keys',
      type: ReportType.lost,
      status: ReportStatus.active,
      categoryNameEn: 'Keys',
      categoryNameAr: 'مفاتيح',
      cityNameEn: 'Cairo',
      cityNameAr: 'القاهرة',
      areaNameEn: 'Zamalek',
      areaNameAr: 'الزمالك',
      itemDate: DateTime(2026, 11, 6),
      images: const [],
      isMine: false,
    ),
    ReportEntity(
      id: 'report-4',
      refCode: 'RPT-1004',
      title: 'Brown leather handbag',
      description: 'Found at City Stars, handed to security.',
      categoryId: 'cat-bags',
      type: ReportType.found,
      status: ReportStatus.recovered,
      categoryNameEn: 'Bags',
      categoryNameAr: 'حقائب',
      cityNameEn: 'Cairo',
      cityNameAr: 'القاهرة',
      areaNameEn: 'Nasr City',
      areaNameAr: 'مدينة نصر',
      itemDate: DateTime(2026, 11, 2),
      images: const ['https://picsum.photos/seed/foundit-bag/200/200'],
      isMine: false,
    ),
    ReportEntity(
      id: 'report-5',
      refCode: 'RPT-1005',
      title: 'University ID card',
      description: 'Cairo University student card, name starts with M.',
      categoryId: 'cat-documents',
      type: ReportType.lost,
      status: ReportStatus.active,
      categoryNameEn: 'Documents',
      categoryNameAr: 'مستندات',
      cityNameEn: 'Cairo',
      cityNameAr: 'القاهرة',
      areaNameEn: 'Maadi',
      areaNameAr: 'المعادي',
      itemDate: DateTime(2026, 11, 5),
      images: const [],
      isMine: true,
    ),
    ReportEntity(
      id: 'report-6',
      refCode: 'RPT-1006',
      title: 'Grey tabby cat',
      description: 'Friendly grey cat with a red collar, near the park.',
      categoryId: 'cat-pets',
      type: ReportType.found,
      status: ReportStatus.active,
      categoryNameEn: 'Pets',
      categoryNameAr: 'حيوانات أليفة',
      cityNameEn: 'Cairo',
      cityNameAr: 'القاهرة',
      areaNameEn: 'Zamalek',
      areaNameAr: 'الزمالك',
      itemDate: DateTime(2026, 11, 1),
      images: const ['https://picsum.photos/seed/foundit-cat/200/200'],
      isMine: false,
    ),
    ReportEntity(
      id: 'report-7',
      refCode: 'RPT-1007',
      title: 'Navy blue backpack',
      description: 'Found in a coffee shop on Road 9.',
      categoryId: 'cat-bags',
      type: ReportType.found,
      status: ReportStatus.active,
      categoryNameEn: 'Bags',
      categoryNameAr: 'حقائب',
      cityNameEn: 'Cairo',
      cityNameAr: 'القاهرة',
      areaNameEn: 'Maadi',
      areaNameAr: 'المعادي',
      itemDate: DateTime(2026, 11, 7),
      images: const [],
      isMine: false,
    ),
    ReportEntity(
      id: 'report-8',
      refCode: 'RPT-1008',
      title: 'iPhone 14, black',
      description: 'Lost in a taxi, lock screen shows a mountain photo.',
      categoryId: 'cat-electronics',
      type: ReportType.lost,
      status: ReportStatus.active,
      categoryNameEn: 'Electronics',
      categoryNameAr: 'إلكترونيات',
      cityNameEn: 'Cairo',
      cityNameAr: 'القاهرة',
      areaNameEn: 'Nasr City',
      areaNameAr: 'مدينة نصر',
      itemDate: DateTime(2026, 10, 30),
      images: const ['https://picsum.photos/seed/foundit-phone/200/200'],
      isMine: false,
    ),
  ];

  /// Mirrors what `search_reports` will do server-side: newest first, with the
  /// query and category/date filters applied.
  static List<ReportEntity> search({
    String query = '',
    String? categoryId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    final needle = query.trim().toLowerCase();
    final from = dateFrom == null ? null : _day(dateFrom);
    final to = dateTo == null ? null : _day(dateTo);

    final results = reports.where((report) {
      if (categoryId != null && report.categoryId != categoryId) return false;

      final day = _day(report.itemDate);
      if (from != null && day.isBefore(from)) return false;
      if (to != null && day.isAfter(to)) return false;

      if (needle.isEmpty) return true;
      final haystack = '${report.title} ${report.description ?? ''}'
          .toLowerCase();
      return haystack.contains(needle);
    }).toList();

    results.sort((a, b) => b.itemDate.compareTo(a.itemDate));
    return results;
  }

  static DateTime _day(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
