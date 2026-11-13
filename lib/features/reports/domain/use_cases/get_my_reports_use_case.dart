import 'package:found_it/features/reports/domain/entities/report_entity.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';

class GetMyReportsUseCase {
  const GetMyReportsUseCase(this._repository);

  final ReportsRepository _repository;

  Future<List<ReportEntity>> call({String? status}) {
    return _repository.getMyReports(status: status);
  }
}
