import 'package:found_it/features/reports/domain/entities/report_entity.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';

class UpdateReportUseCase {
  const UpdateReportUseCase(this._repository);

  final ReportsRepository _repository;

  Future<ReportEntity> call({
    required String reportId,
    String? title,
    String? description,
    String? type,
    String? categoryId,
    String? areaId,
    DateTime? itemDate,
  }) {
    return _repository.updateReport(
      reportId: reportId,
      title: title,
      description: description,
      type: type,
      categoryId: categoryId,
      areaId: areaId,
      itemDate: itemDate,
    );
  }
}
