import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/features/onboarding/data/onboarding_local_data_source.dart';
import 'package:found_it/features/onboarding/data/onboarding_repository_impl.dart';

class _FakeDataSource implements OnboardingLocalDataSource {
  _FakeDataSource(this.first);
  bool first;
  int completedCalls = 0;

  @override
  bool isFirstLaunch() => first;

  @override
  Future<void> setOnboardingCompleted() async {
    completedCalls++;
    first = false;
  }
}

void main() {
  test('isFirstLaunch delegates to data source', () {
    expect(
      OnboardingRepositoryImpl(_FakeDataSource(true)).isFirstLaunch(),
      isTrue,
    );
    expect(
      OnboardingRepositoryImpl(_FakeDataSource(false)).isFirstLaunch(),
      isFalse,
    );
  });

  test('completeOnboarding delegates to data source', () async {
    final ds = _FakeDataSource(true);
    final repo = OnboardingRepositoryImpl(ds);
    await repo.completeOnboarding();
    expect(ds.completedCalls, 1);
    expect(repo.isFirstLaunch(), isFalse);
  });
}
