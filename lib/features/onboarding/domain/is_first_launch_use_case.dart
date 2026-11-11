import 'onboarding_repository.dart';

class IsFirstLaunchUseCase {
  const IsFirstLaunchUseCase(this._repository);

  final OnboardingRepository _repository;

  bool call() => _repository.isFirstLaunch();
}
