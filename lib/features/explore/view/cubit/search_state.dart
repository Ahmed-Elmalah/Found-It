import 'package:equatable/equatable.dart';

import 'package:found_it/core/models/report_type.dart';
import 'package:found_it/features/explore/domain/report_entity.dart';

enum SearchStatus { initial, loading, success, empty, failure }

/// A category as the search UI needs it: id + both localized names.
class CategoryOption extends Equatable {
  const CategoryOption({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  final String id;
  final String nameEn;
  final String nameAr;

  String name(String languageCode) =>
      languageCode.startsWith('ar') ? nameAr : nameEn;

  @override
  List<Object?> get props => [id, nameEn, nameAr];
}

/// An area as the search UI needs it: id + both localized names.
class AreaOption extends Equatable {
  const AreaOption({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  final String id;
  final String nameEn;
  final String nameAr;

  String name(String languageCode) =>
      languageCode.startsWith('ar') ? nameAr : nameEn;

  @override
  List<Object?> get props => [id, nameEn, nameAr];
}

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.type,
    this.categoryIds = const [],
    this.areaIds = const [],
    this.dateFrom,
    this.dateTo,
    this.results = const [],
    this.categories = const [],
    this.areas = const [],
    this.cityNameEn = '',
    this.cityNameAr = '',
    this.errorMessage,
  });

  final SearchStatus status;
  final String query;
  final ReportType? type;
  final List<String> categoryIds;
  final List<String> areaIds;

  /// `YYYY-MM-DD` (the format `search_reports` expects), or null.
  final String? dateFrom;

  /// `YYYY-MM-DD` (the format `search_reports` expects), or null.
  final String? dateTo;

  final List<ReportEntity> results;
  final List<CategoryOption> categories;
  final List<AreaOption> areas;
  final String cityNameEn;
  final String cityNameAr;
  final String? errorMessage;

  bool get isLoading =>
      status == SearchStatus.initial || status == SearchStatus.loading;

  bool get hasActiveFilters =>
      type != null ||
      categoryIds.isNotEmpty ||
      areaIds.isNotEmpty ||
      dateFrom != null ||
      dateTo != null;

  String cityName(String languageCode) =>
      languageCode.startsWith('ar') ? cityNameAr : cityNameEn;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    ReportType? type,
    bool clearType = false,
    List<String>? categoryIds,
    List<String>? areaIds,
    String? dateFrom,
    String? dateTo,
    bool clearDates = false,
    List<ReportEntity>? results,
    List<CategoryOption>? categories,
    List<AreaOption>? areas,
    String? cityNameEn,
    String? cityNameAr,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      type: clearType ? null : (type ?? this.type),
      categoryIds: categoryIds ?? this.categoryIds,
      areaIds: areaIds ?? this.areaIds,
      dateFrom: clearDates ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDates ? null : (dateTo ?? this.dateTo),
      results: results ?? this.results,
      categories: categories ?? this.categories,
      areas: areas ?? this.areas,
      cityNameEn: cityNameEn ?? this.cityNameEn,
      cityNameAr: cityNameAr ?? this.cityNameAr,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    query,
    type,
    categoryIds,
    areaIds,
    dateFrom,
    dateTo,
    results,
    categories,
    areas,
    cityNameEn,
    cityNameAr,
    errorMessage,
  ];
}
