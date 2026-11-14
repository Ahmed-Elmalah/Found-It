import 'package:found_it/features/explore/domain/category_entity.dart';
import 'package:found_it/features/explore/domain/explore_repository.dart';

class GetCategoriesUseCase {
  const GetCategoriesUseCase(this._repository);

  final ExploreRepository _repository;

  Future<List<CategoryEntity>> call() => _repository.getCategories();
}
