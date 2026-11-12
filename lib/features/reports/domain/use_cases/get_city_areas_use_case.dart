import 'package:found_it/features/reports/domain/entities/area_entity.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';

class GetCityAreasUseCase {
  const GetCityAreasUseCase(this._repository);

  final ReportsRepository _repository;

  Future<List<AreaEntity>> call({
    required String cityId,
    String? lang,
  }) {
    return _repository.getCityAreas(cityId: cityId, lang: lang);
  }
}
