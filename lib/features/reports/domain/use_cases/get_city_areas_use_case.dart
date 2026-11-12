import 'package:found_it/features/reports/domain/entities/area_entity.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';

class GetCityAreasUseCase {
  final ReportsRepository _repository;

  const GetCityAreasUseCase(this._repository);

  Future<List<AreaEntity>> call({
    required String cityId,
    required String lang,
  }) =>
      _repository.getCityAreas(cityId: cityId, lang: lang);
}
