import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';

class SoftDeleteReportUseCase {
  const SoftDeleteReportUseCase(this._repository);

  final ReportsRepository _repository;

  Future<void> call(String reportId) {
    return _repository.softDeleteReport(reportId);
  }
}
