import 'package:found_it/features/reports/domain/entities/area_entity.dart';
import 'package:found_it/features/reports/domain/entities/category_entity.dart';
import 'package:found_it/features/reports/domain/entities/create_report_params.dart';
import 'package:found_it/features/reports/domain/entities/report_counts_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_entity.dart';

abstract interface class ReportsRepository {
  /// Fetches reports published by the currently logged-in user.
  /// [status] can be 'active', 'matching', 'recovered', or null for all.
  Future<List<ReportEntity>> getMyReports({String? status});

  /// Fetches the count of reports published by the current user grouped by status.
  Future<ReportCountsEntity> getMyReportsCounts();

  /// Updates details of an existing report.
  Future<ReportEntity> updateReport({
    required String reportId,
    String? title,
    String? description,
    String? type,
    String? categoryId,
    String? areaId,
    DateTime? itemDate,
  });

  /// Soft deletes a report by setting `deleted_at = now()`.
  Future<void> softDeleteReport(String reportId);

  /// Gets all active categories.
  Future<List<CategoryEntity>> getCategories();

  /// Gets all areas belonging to a specific city.
  Future<List<AreaEntity>> getCityAreas({
    required String cityId,
    required String lang,
  });

  /// Creates a new report and returns its refCode.
  Future<String> createReport(CreateReportParams params);

  /// Gets the currently selected city id from preferences.
  Future<String> getSelectedCityId();
}
