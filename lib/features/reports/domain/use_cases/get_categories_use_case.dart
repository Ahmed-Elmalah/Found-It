import 'package:found_it/features/reports/domain/entities/category_entity.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';

class GetCategoriesUseCase {
  final ReportsRepository _repository;

  const GetCategoriesUseCase(this._repository);

  Future<List<CategoryEntity>> call() => _repository.getCategories();
}
