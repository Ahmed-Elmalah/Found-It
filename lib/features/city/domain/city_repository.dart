import 'package:found_it/features/city/domain/city_entity.dart';

abstract interface class CityRepository {
  /// Fetches all active cities sorted by their sort order.
  Future<List<CityEntity>> getCities();

  /// Saves the chosen city for the current user in Supabase and local cache.
  Future<void> selectCity(String cityId);
}
