import 'package:found_it/features/reports/domain/entities/category_entity.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';

class GetCategoriesUseCase {
  const GetCategoriesUseCase(this._repository);

  final ReportsRepository _repository;

  Future<List<CategoryEntity>> call() => _repository.getCategories();
}
