import 'package:found_it/features/reports/domain/entities/report_details_entity.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';

class GetReportDetailsUseCase {
  final ReportsRepository repository;

  const GetReportDetailsUseCase(this.repository);

  Future<ReportDetailsEntity> call(String reportId) =>
      repository.getReportDetails(reportId);
}
