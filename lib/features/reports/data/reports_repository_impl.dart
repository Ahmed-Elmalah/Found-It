import 'package:found_it/features/reports/data/reports_data_source.dart';
import 'package:found_it/features/reports/domain/entities/area_entity.dart';
import 'package:found_it/features/reports/domain/entities/category_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_counts_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_entity.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  const ReportsRepositoryImpl(this._dataSource);

  final ReportsDataSource _dataSource;

  @override
  Future<List<ReportEntity>> getMyReports({String? status}) {
    return _dataSource.getMyReports(status: status);
  }

  @override
  Future<ReportCountsEntity> getMyReportsCounts() {
    return _dataSource.getMyReportsCounts();
  }

  @override
  Future<ReportEntity> updateReport({
    required String reportId,
    String? title,
    String? description,
    String? type,
    String? categoryId,
    String? areaId,
    DateTime? itemDate,
  }) {
    return _dataSource.updateReport(
      reportId: reportId,
      title: title,
      description: description,
      type: type,
      categoryId: categoryId,
      areaId: areaId,
      itemDate: itemDate,
    );
  }

  @override
  Future<void> softDeleteReport(String reportId) {
    return _dataSource.softDeleteReport(reportId);
  }

  @override
  Future<List<CategoryEntity>> getCategories() {
    return _dataSource.getCategories();
  }

  @override
  Future<List<AreaEntity>> getCityAreas({
    required String cityId,
    String? lang,
  }) {
    return _dataSource.getCityAreas(cityId: cityId, lang: lang);
  }
}
