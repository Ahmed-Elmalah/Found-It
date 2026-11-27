import 'package:found_it/features/reports/domain/entities/manual_match_result_entity.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';

class CreateManualMatchUseCase {
  final ReportsRepository repository;

  const CreateManualMatchUseCase(this.repository);

  Future<ManualMatchResultEntity> call(String reportId) =>
      repository.createManualMatch(reportId);
}
