import 'package:found_it/features/reports/domain/entities/area_entity.dart';
import 'package:found_it/features/reports/domain/entities/category_entity.dart';
import 'package:found_it/features/reports/domain/entities/create_report_params.dart';

abstract class ReportsRepository {
  Future<List<CategoryEntity>> getCategories();
  Future<List<AreaEntity>> getCityAreas({
    required String cityId,
    required String lang,
  });
  Future<String> createReport(CreateReportParams params);
  Future<String> getSelectedCityId();
}
