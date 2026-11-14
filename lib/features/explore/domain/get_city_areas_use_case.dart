import 'package:found_it/features/explore/domain/area_entity.dart';
import 'package:found_it/features/explore/domain/explore_repository.dart';

class GetCityAreasUseCase {
  const GetCityAreasUseCase(this._repository);

  final ExploreRepository _repository;

  Future<List<AreaEntity>> call({required String cityId, String lang = 'en'}) {
    return _repository.getCityAreas(cityId: cityId, lang: lang);
  }
}
