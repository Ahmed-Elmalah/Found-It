import 'package:found_it/features/reports/domain/entities/report_counts_entity.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';

class GetMyReportsCountsUseCase {
  const GetMyReportsCountsUseCase(this._repository);

  final ReportsRepository _repository;

  Future<ReportCountsEntity> call() {
    return _repository.getMyReportsCounts();
  }
}
