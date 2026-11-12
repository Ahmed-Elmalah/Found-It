import 'package:found_it/features/city/domain/repositories/city_repository.dart';

class SelectCityUseCase {
  const SelectCityUseCase(this._repository);

  final CityRepository _repository;

  Future<void> call(String cityId) => _repository.selectCity(cityId);
}
