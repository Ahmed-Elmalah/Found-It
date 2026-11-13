import 'package:found_it/features/reports/domain/entities/create_report_params.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';

class CreateReportUseCase {
  final ReportsRepository _repository;

  const CreateReportUseCase(this._repository);

  Future<String> call(CreateReportParams params) =>
      _repository.createReport(params);
}
