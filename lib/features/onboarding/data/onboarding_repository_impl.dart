import 'package:found_it/features/onboarding/domain/onboarding_repository.dart';

import 'onboarding_local_data_source.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl(this._dataSource);

  final OnboardingLocalDataSource _dataSource;

  @override
  bool isFirstLaunch() => _dataSource.isFirstLaunch();

  @override
  Future<void> completeOnboarding() => _dataSource.setOnboardingCompleted();
}
