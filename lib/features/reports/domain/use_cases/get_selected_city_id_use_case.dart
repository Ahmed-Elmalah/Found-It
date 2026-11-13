import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';

class GetSelectedCityIdUseCase {
  final ReportsRepository _repository;

  const GetSelectedCityIdUseCase(this._repository);

  Future<String> call() => _repository.getSelectedCityId();
}
